#/usr/bin/env ruby
require "fox16"
require "uri"

require "./gopher"

include Fox

class MainWindow < FXMainWindow	
	def initialize(app, title, w, h)	
		super(app, title, :width => w, :height => h)
		toolbar = FXToolBar.new(self)
		
		up = FXButton.new(toolbar, "Up")
		
		url = FXTextField.new(toolbar, 50)
		url.text = "gopher://gopher.floodgap.com/"
		
		go = FXButton.new(toolbar, "->")
	
		@iconList = FXIconList.new(self, nil, 0, ICONLIST_MINI_ICONS|ICONLIST_AUTOSIZE|ICONLIST_COLUMNS|LAYOUT_FILL_X|LAYOUT_FILL_Y)
		
		go.connect(SEL_COMMAND) do
			self.navigate(url.text)
		end
		
		@items = Array.new
		
		@iconList.connect(SEL_CLICKED) do |sender, sel, index|
			if @items[index][:type] == "1" then
				target = "gopher://" + @items[index][:host] + @items[index][:path]
				url.text = target
				navigate(url.text)
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
		
		@items.each do |item|
			icon = nil
			
			if item[:type] == "i" then
				icon = FXPNGIcon.new(app, File.open("icons/blank.png", "rb").read)
				icon.create
			elsif item[:type] == "1" then
				icon = FXPNGIcon.new(app, File.open("icons/folder.png", "rb").read)
				icon.create
			elsif item[:type] == "0" or item[:type] == "5" or item[:type] == "9" then
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
