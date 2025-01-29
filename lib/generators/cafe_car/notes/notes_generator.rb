class CafeCar::NotesGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def create_notes
    migration "create_notes"
    template "note.rb", "app/models/note.rb"
    template "notable.rb", "app/models/concerns/notable.rb"
    generate "cafe_car:policy", "Note notable_id notable_type body", ("--force" if options.force?)
    generate "cafe_car:controller", "admin/notes"
  end
end
