require "../../../src/change/sql/query"

def select_expr(column)
  Change::SQL::SelectExpr.new(column: column)
end

def from_expr(table)
  Change::SQL::FromExpr.new(table: table)
end

def where_expr(criterion, op, value)
  Change::SQL::WhereExpr.new(criterion: criterion, op: op, value: value)
end

def update_expr(criterion, value)
  Change::SQL::UpdateExpr.new(criterion: criterion, value: value)
end

def order_expr(criterion, direction)
  Change::SQL::OrderExpr.new(criterion: criterion, direction: direction.to_s)
end
