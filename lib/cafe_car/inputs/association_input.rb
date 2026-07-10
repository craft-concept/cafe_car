module CafeCar
  module Inputs
    # A `<select>` over an association's records (belongs_to / has_many). Delegates
    # to the form builder's `association`, which caps the collection, guarantees the
    # currently-associated record is present, and flags the select for typeahead
    # enhancement when the associated model exposes an options feed.
    class AssociationInput < BaseInput
      def helper = :association
    end
  end
end
