class InvoicePresenter < CafeCar::Presenter
  show :total, as: :currency
  show :number, -> { "#%03d" % _1.object }

  def title = show(:number)
end
