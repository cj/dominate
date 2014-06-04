class SomeWidget < Dominate::Widget
  def display
    @var = 'World!'
    render.html
  end

  def hello
    "Hello, World!"
  end
end
