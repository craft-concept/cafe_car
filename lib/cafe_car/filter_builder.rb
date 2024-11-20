module CafeCar
  class FilterBuilder
    require "activerecord_where_assoc"

    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def update!(&)
      scope  = instance_exec(@scope, &)
      @scope = scope if scope
      self
    end

    def association?(name) = @scope.reflect_on_association(name).present?

    def param!(key, value)
      association?(key) ? association!(key, value) : attribute!(key, value)
    end

    def attribute!(key, value)
      @scope.where!(key => value)
      self
    end

    def association!(name, value, ...)
      update! do
        case value
        when true then  @scope.where_assoc_exists(name)
        when false then @scope.where_assoc_not_exists(name)
        else            @scope.where_assoc_exists(name) { filtered(value, ...) }
        end
      end
    end

    def filter!(params = nil)
      params.each { param!(_1, _2) } if params
      self
    end

    def filter(...) = update!(&:all).filter!(...)
  end
end

# Article.filtered do
#   published
#   user { username(/bob/) }
#   user.username(/bob/)
# end
#
# Article.filtered(published: true, user: {username: /bob/})
#
# Article.published(true).where_assoc_exists(:user) { where(username: /bob/) }
