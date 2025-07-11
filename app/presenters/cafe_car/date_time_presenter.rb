module CafeCar
  class DateTimePresenter < Presenter
    def distance = @template.time_ago_in_words(object)
    def words    = object.past? ? "#{distance} ago" : "in #{distance}"
    def datetime = object.iso8601
    def title    = l(object, format: :long)

    def string  = words
    def to_html = tag.time words, datetime:, title:
  end
end
