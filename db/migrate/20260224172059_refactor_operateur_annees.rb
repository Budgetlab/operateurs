# frozen_string_literal: true

class RefactorOperateurAnnees < ActiveRecord::Migration[8.1]
  def up
    # Task 1.1: Add annees integer[] to operateurs
    add_column :operateurs, :annees, :integer, array: true, default: []

    # Task 1.2: Add operateur_actif boolean to organismes
    add_column :organismes, :operateur_actif, :boolean, default: false

    # Task 1.3 / 1.4 / 1.5 / 1.6: Data migration using PL/pgSQL for contiguous-range logic
    # Active: operateur_n OR operateur_nf → store start of contiguous block + disconnected past years
    # Inactive: only n1/n2 true → store all individual years
    execute <<~SQL
          DO $$
          DECLARE
            rec RECORD;
            true_years INTEGER[];
            active_block_start INTEGER;
            past_years INTEGER[];
            final_annees INTEGER[];
            i INTEGER;
            yr INTEGER;
            prev_yr INTEGER;
            in_active_block BOOLEAN;
          BEGIN
            FOR rec IN SELECT id, operateur_n, operateur_n1, operateur_n2, operateur_nf FROM operateurs LOOP
              -- Build sorted array of true years
              true_years := ARRAY[]::INTEGER[];
              IF rec.operateur_n2 THEN true_years := true_years || 2024; END IF;
              IF rec.operateur_n1 THEN true_years := true_years || 2025; END IF;
              IF rec.operateur_n  THEN true_years := true_years || 2026; END IF;
              IF rec.operateur_nf THEN true_years := true_years || 2027; END IF;

              IF rec.operateur_n OR rec.operateur_nf THEN
                -- ACTIVE operator
                -- Find contiguous block that includes 2026 or 2027 (current/future)
                -- Walk backwards from the highest active year to find contiguous range start
                active_block_start := NULL;
                in_active_block := FALSE;
                prev_yr := NULL;

                -- Iterate from highest to lowest year to find block touching 2026/2027
                FOR i IN REVERSE array_length(true_years, 1)..1 LOOP
                  yr := true_years[i];
                  IF prev_yr IS NULL THEN
                    -- First (highest) year — must be 2026 or 2027 since operateur_n/nf is true
                    IF yr = 2026 OR yr = 2027 THEN
                      in_active_block := TRUE;
                      active_block_start := yr;
                    END IF;
                  ELSE
                    IF in_active_block AND prev_yr - yr = 1 THEN
                      -- Contiguous with previous
                      active_block_start := yr;
                    ELSE
                      in_active_block := FALSE;
                    END IF;
                  END IF;
                  prev_yr := yr;
                END LOOP;

                -- Collect past years (years < active_block_start that are NOT part of the active block)
                past_years := ARRAY[]::INTEGER[];
                FOR i IN 1..array_length(true_years, 1) LOOP
                  yr := true_years[i];
                  EXIT WHEN yr >= active_block_start;
                  past_years := past_years || yr;
                END LOOP;

                -- final = past individual years + start of active block
                final_annees := past_years || active_block_start;

                UPDATE operateurs SET annees = final_annees WHERE id = rec.id;
                UPDATE organismes SET operateur_actif = TRUE WHERE id = (SELECT organisme_id FROM operateurs WHERE id = rec.id);

              ELSIF array_length(true_years, 1) > 0 THEN
                -- INACTIVE but has some past years
                final_annees := true_years;
                UPDATE operateurs SET annees = final_annees WHERE id = rec.id;
                -- operateur_actif remains false (default)

              ELSE
                -- All false: empty array (default already)
                -- operateur_actif remains false
                NULL;
              END IF;

            END LOOP;
          END;
          $$;
    SQL

    # Task 1.7: Drop the 4 boolean columns
    remove_column :operateurs, :operateur_nf
    remove_column :operateurs, :operateur_n
    remove_column :operateurs, :operateur_n1
    remove_column :operateurs, :operateur_n2

    # Task 1.8: Add GIN index on annees
    add_index :operateurs, :annees, using: :gin
  end

  def down
    # Task 1.9: Reverse migration — restore boolean columns from annees
    remove_index :operateurs, :annees

    add_column :operateurs, :operateur_nf, :boolean
    add_column :operateurs, :operateur_n,  :boolean
    add_column :operateurs, :operateur_n1, :boolean
    add_column :operateurs, :operateur_n2, :boolean

    # Reverse data migration: expand annees back to individual boolean columns.
    # For active operators, the highest year in annees is the start of a contiguous
    # range up to 2027. Past individual years are also stored separately.
    # For inactive operators, annees stores all individual years directly.
    execute <<~SQL
      DO $$
      DECLARE
        rec RECORD;
        is_active BOOLEAN;
        max_yr INTEGER;
        yr INTEGER;
        expanded_years INTEGER[];
      BEGIN
        FOR rec IN SELECT o.id, o.annees, o.organisme_id,
                          COALESCE(org.operateur_actif, FALSE) AS operateur_actif
                   FROM operateurs o
                   JOIN organismes org ON org.id = o.organisme_id LOOP

          IF rec.annees IS NULL OR array_length(rec.annees, 1) IS NULL THEN
            -- Empty annees: all booleans false (default)
            UPDATE operateurs SET
              operateur_nf = FALSE, operateur_n = FALSE,
              operateur_n1 = FALSE, operateur_n2 = FALSE
            WHERE id = rec.id;
            CONTINUE;
          END IF;

          IF rec.operateur_actif THEN
            -- Active: find the max year in annees (= active block start),
            -- expand from that year to 2027, keep other years as individual
            max_yr := (SELECT MAX(y) FROM unnest(rec.annees) y);
            expanded_years := rec.annees;
            -- Add all years from max_yr to 2027
            FOR yr IN max_yr..2027 LOOP
              IF NOT (yr = ANY(expanded_years)) THEN
                expanded_years := expanded_years || yr;
              END IF;
            END LOOP;
          ELSE
            -- Inactive: annees are already individual years
            expanded_years := rec.annees;
          END IF;

          UPDATE operateurs SET
            operateur_nf = (2027 = ANY(expanded_years)),
            operateur_n  = (2026 = ANY(expanded_years)),
            operateur_n1 = (2025 = ANY(expanded_years)),
            operateur_n2 = (2024 = ANY(expanded_years))
          WHERE id = rec.id;

        END LOOP;
      END;
      $$;
    SQL

    remove_column :operateurs, :annees
    remove_column :organismes, :operateur_actif
  end
end
