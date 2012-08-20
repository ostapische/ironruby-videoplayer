require "PresentationFramework"
include System::Windows
include System::Windows::Markup

xaml = File.open('videoplayer.xaml', 'r').read

@root = XamlReader.parse(xaml)

app = Application.new

app.run @root