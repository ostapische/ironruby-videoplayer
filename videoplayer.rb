version = System::Environment.Version.Major == 4 ? "4.0.0.0" : "3.0.0.0"
require "PresentationFramework, Version=#{version}, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
require "PresentationCore, Version=#{version}, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
require "System.Core, Version=#{version}, Culture=neutral, PublicKeyToken=b77a5c561934e089"
require "WindowsBase, Version=#{version}, Culture=neutral, PublicKeyToken=31bf3856ad364e35"

include System
include System::Windows
include System::Windows::Controls
include System::Windows::Input
include System::Windows::Markup
include System::Windows::Media

class Player
	def initialize
		@video_formats=["avi", "flv", "wmv", "mp4", "mp3"]
		@main_window = Window.new
			@main_window.Name = 'main_window'
			@main_window.Title = 'IronRuby Videoplayer'
			@main_window.Width = '800'
			@main_window.Height = '600'
				
			@main_grid = Grid.new
				@main_grid.Name = 'main_grid'
				@main_grid.Background = SolidColorBrush.new(Colors.Black)
				@main_grid.HorizontalAlignment = HorizontalAlignment.Stretch
				@main_grid.VerticalAlignment = VerticalAlignment.Stretch
					
				main_grid_column_definition = ColumnDefinition.new
					main_grid_column_definition.Width = GridLength.new(80, GridUnitType.Star)
				@main_grid.ColumnDefinitions.Add(main_grid_column_definition)
				main_grid_column_definition = ColumnDefinition.new
					main_grid_column_definition.Width = GridLength.new(20, GridUnitType.Star)
				@main_grid.ColumnDefinitions.Add(main_grid_column_definition)
					
				main_grid_row_definition = RowDefinition.new
					main_grid_row_definition.Height = GridLength.new(100, GridUnitType.Star)
				@main_grid.RowDefinitions.Add(main_grid_row_definition)
				main_grid_row_definition = RowDefinition.new
					main_grid_row_definition.Height = GridLength.new(20, GridUnitType.Pixel)
				@main_grid.RowDefinitions.Add(main_grid_row_definition)
					
				@main_media_element = MediaElement.new
					@main_media_element.Name = 'main_media_element'
					@main_media_element.LoadedBehavior = MediaState.Manual
					@main_media_element.UnloadedBehavior = MediaState.Stop
					Grid.SetRow(@main_media_element, 0)
					Grid.SetColumn(@main_media_element, 0)
				@main_grid.Children.Add(@main_media_element)
					
				@buttons_stack_panel = StackPanel.new
					@buttons_stack_panel.Name = 'buttons_stack_panel'
					@buttons_stack_panel.Orientation = Orientation.Horizontal
					Grid.SetRow(@buttons_stack_panel, 1)
					Grid.SetColumn(@buttons_stack_panel, 0)
						
					@play_button = Button.new
						@play_button.Name = 'play_button'
						@play_button.Content = 'Play'
						
						on_play_button_mouse_click = RoutedEventHandler.new { |sender, e| play_button_mouse_click(sender, e) }
						play_button_mouse_click_event = @play_button.GetType.get_event("Click")
						play_button_mouse_click_event.add_event_handler(@play_button, on_play_button_mouse_click)
					@buttons_stack_panel.Children.Add(@play_button)
						
					@pause_button = Button.new
						@pause_button.Name = 'pause_button'
						@pause_button.Content = 'Pause'
						
						on_pause_button_mouse_click = RoutedEventHandler.new { |sender, e| pause_button_mouse_click(sender, e) }
						pause_button_mouse_click_event = @pause_button.GetType.get_event("Click")
						pause_button_mouse_click_event.add_event_handler(@pause_button, on_pause_button_mouse_click)
					@buttons_stack_panel.Children.Add(@pause_button)
						
					@stop_button = Button.new
						@stop_button.Name = 'stop_button'
						@stop_button.Content = 'Stop'
						
						on_stop_button_mouse_click = RoutedEventHandler.new { |sender, e| stop_button_mouse_click(sender, e) }
						stop_button_mouse_click_event = @stop_button.GetType.get_event("Click")
						stop_button_mouse_click_event.add_event_handler(@stop_button, on_stop_button_mouse_click)
					@buttons_stack_panel.Children.Add(@stop_button)
						
				@main_grid.Children.Add(@buttons_stack_panel)
					
				@files_list_box = ListBox.new
					@files_list_box.Name = 'files_list_box'
					@files_list_box.AllowDrop = true
					Grid.SetRow(@files_list_box, 0)
					Grid.SetColumn(@files_list_box, 1)
						
					on_files_list_box_drop = DragEventHandler.new { |sender, e| files_list_box_drop(sender, e) }
					files_list_box_drop_event = @files_list_box.GetType.get_event("Drop")
					files_list_box_drop_event.add_event_handler(@files_list_box, on_files_list_box_drop)
				
					on_files_list_box_selection_changed = SelectionChangedEventHandler.new {|sender, e| files_list_box_selection_changed(sender, e)}
					files_list_box_selection_changed_event = @files_list_box.GetType.get_event("SelectionChanged")
					files_list_box_selection_changed_event.add_event_handler(@files_list_box, on_files_list_box_selection_changed)
					
				@main_grid.Children.Add(@files_list_box)
				
			@main_window.Content = @main_grid
	end
	
	def run!
		app = Application.new
		app.run(@main_window)
	end
	
	def files_list_box_drop(sender, e)
		if e.Data.ContainsFileDropList()
			for file_path in e.Data.GetFileDropList()
				if !@video_formats.index(file_path.split('.').reverse()[0].downcase).nil?
					item=ListBoxItem.new
						stack_panel = StackPanel.new
							text_block = TextBlock.new
								text_block.Text = file_path.split('\\').reverse()[0]
								text_block.Name = 'file_name'
							stack_panel.Children.Add(text_block)
							text_block = TextBlock.new
								text_block.Text = file_path
								text_block.Name = 'file_path'
								text_block.Visibility = Visibility.Collapsed
							stack_panel.Children.Add(text_block)
						item.Content = stack_panel
					@files_list_box.Items.Add(item)
				end
			end
		end
	end
	
	def files_list_box_selection_changed(sender, e)
		file_path = sender.Items[sender.SelectedIndex].Content.Children[1].Text
		@main_media_element.Source = Uri.new(file_path)
	end
	
	def play_button_mouse_click(sender, e)
		@main_media_element.Play()
	end
	
	def pause_button_mouse_click(sender, e)
		@main_media_element.Pause()
	end
	
	def stop_button_mouse_click(sender, e)
		@main_media_element.Stop()
	end
end

player = Player.new
player.run!