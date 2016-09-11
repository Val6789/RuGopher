#!/usr/bin/env ruby
require "fox16"
require "uri"

require "./gopher"
require "./text_dialog"

include Fox

class MainWindow < FXMainWindow	
	def initialize(app, title, w, h)	
		super(app, title, :width => w, :height => h)
		@icons = {
			:blank => FXPNGIcon.new(app, File.open("icons/blank.png", "rb").read),
			:folder => FXPNGIcon.new(app, File.open("icons/folder.png", "rb").read),
			:text => FXPNGIcon.new(app, File.open("icons/text.png", "rb").read),
			:file => FXPNGIcon.new(app, File.open("icons/file.png", "rb").read),
			:pic => FXPNGIcon.new(app, File.open("icons/pic.png", "rb").read),
			:left => FXPNGIcon.new(app, File.open("icons/left.png", "rb").read),
			:right => FXPNGIcon.new(app, File.open("icons/right.png", "rb").read),
			:up => FXPNGIcon.new(app, File.open("icons/up.png", "rb").read)
		}
		@icons.each { |i, icon| icon.create }
		
		toolbar = FXToolBar.new(self)
		
		back = FXButton.new(toolbar, "Back", @icons[:left])
		up = FXButton.new(toolbar, "Up", @icons[:up])
		
		@url = FXTextField.new(toolbar, 50, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		@url.text = "gopher://gopher.floodgap.com/"
		
		go = FXButton.new(toolbar, "Go", @icons[:right])
	
		@iconList = FXIconList.new(self, nil, 0, ICONLIST_MINI_ICONS|ICONLIST_AUTOSIZE|ICONLIST_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y)
		
		back.connect(SEL_COMMAND) do
			# TODO
		end
		
		go.connect(SEL_COMMAND) do
			self.navigate(@url.text)
		end
		
		@items = Array.new
		@textdialog = TextDialog.new(self)
		
		@iconList.connect(SEL_CLICKED) do |sender, sel, index|
			item_click(sender, sel, index)
		end
				
		up.connect(SEL_COMMAND) do
			target = File.dirname @url.text
			if target != "gopher:" # If we are not at the root dir
				@url.text = target
				self.navigate(@url.text)
			end
		end
	end
		
	def create	
		super	
		show(PLACEMENT_SCREEN)	
	end
	
	def navigate(target)
		uri = URI(target)
		
		uri.port ? port = uri.port : port = 70
		
		begin
			@items = Gopher.new(uri.host, port).list(uri.path)
		rescue => msg
			FXMessageBox.error(self, MBOX_OK, "Error", "Network error:\n" + msg.to_s)
			@items = []
		end
		
		@iconList.clearItems()
		# Populate the file list
		@items.each do |item|
			icon = nil
			
			if item[:type] == "i" then
				icon = @icons[:blank]
			elsif item[:type] == "1" then
				icon = @icons[:folder]
			elsif item[:type] == "0" then
				icon = @icons[:text]
			elsif item[:type] == "4" or item[:type] == "5" or item[:type] == "6" or item[:type] == "9" then
				icon = @icons[:file]
			elsif item[:type] == "I" or item[:type] == "p" or item[:type] == "g" then
				icon = @icons[:pic]
			end
			
			@iconList.appendItem(item[:description], nil, icon)
		end
	end
	
	def item_click(sender, sel, index)
		if @items[index][:type] == "1" then
			target = "gopher://" + @items[index][:host] + @items[index][:path]
			@url.text = target
			navigate(@url.text)
		elsif @items[index][:type] == "0" then
			# Display the text file in a dialog window
			data = Gopher.new(@items[index][:host], @items[index][:port]).get(@items[index][:path])
			
			@textdialog.configure(data, @items[index][:description])
			@textdialog.show
			elsif @items[index][:type] == "4" or @items[index][:type] == "5" or @items[index][:type] == "6" or @items[index][:type] == "9" then
			# Download a file
			dest = FXFileDialog.getSaveFilename(self, "Save file as...", "")
			if not dest.empty? then
				Gopher.new(@items[index][:host], @items[index][:port]).download(@items[index][:path], dest)
			end
		elsif @items[index][:type] == "I" or @items[index][:type] == "p" or @items[index][:type] == "g"
			# Displays a picture
			dest = "/tmp/RuGopher-pic-" + rand(0..10000).to_s + File.extname(@items[index][:path])
			Gopher.new(@items[index][:host], @items[index][:port]).download(@items[index][:path], dest)
			system("xdg-open " + dest)
		else
			puts "Unknown type: " + @items[index][:type] + " path: " + @items[index][:path]
		end
	end
end	

app = FXApp.new	
MainWindow.new(app, "RuGopher", 800, 600)	
app.create	
app.run	
