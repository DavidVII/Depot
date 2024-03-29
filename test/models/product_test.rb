require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = Product.new(title:       'My book title',
                          description: 'yyy',
                          image_url:   'zzz.png')
    product.price = -1
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
      product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
      product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    product = Product.new(title:       'My book title',
                          description: 'yyy',
                          price:       1,
                          image_url:   image_url)
  end

  test 'image url' do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FReD.Jpg http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.fig/more fred.gif.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} should be invalid"
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new( title:       products(:ruby).title,
                           description: 'yyy',
                           price:       1,
                           image_url:   'fred.gif'
                         )
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end

  test 'product is not valid without a unique title - i18n' do
    product = Product.new( title:       products(:ruby).title,
                           description: 'yyy',
                           price:       1,
                           image_url:   'fred.gif'
                         )
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
      product.errors[:title]
  end

  test 'product title is at least 10 characters long' do
    short_title = "a" * 9
    product = Product.new( title: short_title, description: 'yyy',
                           price: 1, image_url: 'fred.gif' )
    assert product.invalid?, product.errors[:title]
  end

  test 'product title is too long' do
    long_title = "a" * 51
    product = Product.new( title: long_title, description: 'yyy',
                           price: 1, image_url: 'fred.gif' )
    assert product.invalid?, product.errors[:title]
  end
end
