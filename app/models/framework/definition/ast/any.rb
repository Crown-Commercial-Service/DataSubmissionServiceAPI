class Framework
  module Definition
    module AST
      Any = Class.new do
        def downcase
          self
        end

        def ==(_other)
          true
        end

        def to_s
          '*'
        end

        def inspect
          '<Any>'
        end
      end.new
    end
  end
end
