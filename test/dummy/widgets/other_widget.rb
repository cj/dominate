class OtherWidget < Dominate::Widget
  respond_to :test, for: :some_widget, with: :some_widget_test

  def display
    render
  end

  def some_widget_test
    res.write 'cow'
  end
end
