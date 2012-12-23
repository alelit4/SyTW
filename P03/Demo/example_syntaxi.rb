require 'syntaxi'

text = <<"EOF"
[code lang="ruby"]
  def foo
    puts 'bar'
  end
[/code]
EOF

formatted_text = Syntaxi.new(text).process
puts formatted_text