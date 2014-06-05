class SomeWidget < Dominate::Widget
  respond_to :test

  def display
    @var = 'World!'

    render
  end

  def test data
    render
  end

  def hello
    "Hello, World!"
  end
end
