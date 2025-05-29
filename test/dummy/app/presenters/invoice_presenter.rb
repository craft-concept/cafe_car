class InvoicePresenter < CafeCar::Presenter
  show :total, as: :currency
  show :number do |number|
    "#%03d" % number.object
  end

  def title = show(:number)
end
