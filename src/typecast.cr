module Change
  module TypeCast
    macro def_cast(given, target)
      def self.cast(value : {{given.id}}, target : {{target.id}}.class) : {{target.id}}?
        return nil if value.nil?
        {{yield}}
      end
    end

    def_cast(_, Nil){ nil }
    def_cast(_, String){ value.to_s }
    def_cast(_, Int){ value.to_i }
    def_cast(_, Int32){ value.to_i32 }
    def_cast(_, Int64){ value.to_i64 }
  end
end
