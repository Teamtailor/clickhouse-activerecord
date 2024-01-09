require 'arel/visitors/to_sql'

module ClickhouseActiverecord
  module Arel
    module Visitors
      class ToSql < ::Arel::Visitors::ToSql

        def aggregate(name, o, collector)
          # replacing function name for materialized view
          if o.expressions.first && o.expressions.first != '*' && !o.expressions.first.is_a?(String) && o.expressions.first.relation&.is_view
            super("#{name.downcase}Merge", o, collector)
          else
            super
          end
        end

        def visit_Arel_Nodes_UpdateStatement(o, collector)
          o = prepare_update_statement(o)

          collector << 'ALTER TABLE '
          collector = visit o.relation, collector
          collect_nodes_for o.values, collector, ' UPDATE '
          collect_nodes_for o.wheres, collector, ' WHERE ', ' AND '
          collect_nodes_for o.orders, collector, ' ORDER BY '
          maybe_visit o.limit, collector
        end
      end
    end
  end
end
