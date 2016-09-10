#!/usr/bin/env ruby
require "fox16"
require "uri"

require "./gopher"
require "./text_dialog"

include Fox

class MainWindow < FXMainWindow	
	def initialize(app, title, w, h)	
		super(app, title, :width => w, :height => h)
		toolbar = FXToolBar.new(self)
		
		up = FXButton.new(toolbar, "Up")
		
		url = FXTextField.new(toolbar, 50, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		url.text = "gopher://gopher.floodgap.com/"
		
		go = FXButton.new(toolbar, "->")
	
		@iconList = FXIconList.new(self, nil, 0, ICONLIST_MINI_ICONS|ICONLIST_AUTOSIZE|ICONLIST_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y)
		
		go.connect(SEL_COMMAND) do
			self.navigate(url.text)
		end
		
		@items = Array.new
		@textdialog = TextDialog.new(self)
		
		@iconList.connect(SEL_CLICKED) do |sender, sel, index|
			if @items[index][:type] == "1" then
				target = "gopher://" + @items[index][:host] + @items[index][:path]
				url.text = target
				navigate(url.text)
			elsif @items[index][:type] == "0" then
				# Display the text file in a dialog window
				data = Gopher.new(@items[index][:host], @items[index][:port]).get(@items[index][:path])
				
				@textdialog.configure(data, @items[index][:description])
				@textdialog.show
			end
		end
				
		up.connect(SEL_COMMAND) do
			target = File.dirname url.text
			if target != "gopher:" # If we are not at the root dir
				url.text = target
				self.navigate(url.text)
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
		
		@iconList.clearItems()
		@items = Gopher.new(uri.host, port).list(uri.path)
		
		# Populate the file list
		@items.each do |item|
			icon = nil
			
			# TODO optimize this (don't create icons everytime)
			if item[:type] == "i" then
				icon = FXPNGIcon.new(app, File.open("icons/blank.png", "rb").read)
				icon.create
			elsif item[:type] == "1" then
				icon = FXPNGIcon.new(app, File.open("icons/folder.png", "rb").read)
				icon.create
			elsif item[:type] == "0" then
				icon = FXPNGIcon.new(app, File.open("icons/text.png", "rb").read)
				icon.create
			elsif item[:type] == "5" or item[:type] == "9" then
				icon = FXPNGIcon.new(app, File.open("icons/file.png", "rb").read)
				icon.create
			end
			
			@iconList.appendItem(item[:description], nil, icon)
		end
	end
end	

app = FXApp.new	
MainWindow.new(app, "RuGopher", 800, 600)	
app.create	
app.run	
