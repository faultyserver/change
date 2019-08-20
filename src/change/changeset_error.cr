module Change
  class ChangesetError
    property field : String
    property message : String

    def initialize(@field : String, @message : String)
    end
  end
end
