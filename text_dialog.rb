require "fox16"

include Fox

# Dialog box for displaying text files
class TextDialog < FXDialogBox
	def initialize(owner)
		super(owner, "RuGopher", DECOR_TITLE|DECOR_BORDER|DECOR_CLOSE|DECOR_STRETCHABLE, 0, 0, 680, 550)
		
		@text = FXText.new(self, nil, 0, TEXT_READONLY|LAYOUT_FILL_X|LAYOUT_FILL_Y)
		@text.font = FXFont.new(getApp(), "Monospace", 10)
	end
	
	# TODO also change window title according to filename
	def configure(data, filename)
		@text.setText(data.gsub("\r", ""))
	end
end
