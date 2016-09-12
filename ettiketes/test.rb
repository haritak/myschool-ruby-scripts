#https://github.com/madriska/prawn-labels
require 'prawn/labels'

names = ["Jordan", "Chris", "Jon", "Mike", "Kelly", "Bob", "Greg"]

Prawn::Labels.generate("names.pdf", names, :type => "Avery18036") do |pdf, name|
    pdf.text name
end
