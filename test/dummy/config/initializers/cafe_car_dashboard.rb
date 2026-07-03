# Demo-only dashboard for the dummy app / live demo — exercises the CafeCar
# dashboard DSL end to end (two metric tiles + a chart). This lives in test/dummy,
# NOT the shipped gem: a real host declares its own dashboard in an initializer.
#
# Declared inside `to_prepare` so the app's models (Article) are autoloaded when
# the block runs, and re-declared cleanly on each code reload.
Rails.application.config.to_prepare do
  CafeCar.dashboard do
    metric "Articles",  -> { Article.count }
    metric "Published", -> { Article.where.not(published_at: nil).count }
    chart  "Articles by month", model: Article, x: :created_at, by: :month
  end
end
