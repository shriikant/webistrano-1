require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should_not_allow_for_non_admins_to_create_users" do
    login

    assert_no_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  test "should_allow_for_admins_to_create_users" do
    admin_login

    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  test "should_require_login_on_signup" do
    admin_login

    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert_not_empty assigns(:user).errors[:login]
      assert_response :success
    end
  end

  test "non_admins_can_not_delete_users" do
    User.delete_all
    user_1 = FactoryGirl.create(:user, :login => 'user_1')
    user_2 = FactoryGirl.create(:user, :login => 'user_2')
    user_3 = FactoryGirl.create(:user, :login => 'user_3')
    admin = FactoryGirl.create(:user, :login => 'admin')
    admin.make_admin!

    # login as non-admin
    assert !user_1.admin?
    login(user_1)
    delete :destroy, :id => user_2.id
    assert_equal 4, User.count
    assert_match 'Action not allowed', flash[:notice]

  end

  test "admins_can_delete_users" do
    User.delete_all
    user_1 = FactoryGirl.create(:user)
    user_2 = FactoryGirl.create(:user)
    user_3 = FactoryGirl.create(:user)
    admin = FactoryGirl.create(:user)
    admin.make_admin!

    assert admin.admin?
    login(admin)
    delete :destroy, :id => user_2.id
    assert_equal 3, User.enabled.count
  end

  test "admin_status_can_not_be_set_by_non_admins" do
    user_1 = FactoryGirl.create(:user)
    user_2 = FactoryGirl.create(:user)

    assert !user_1.admin?
    assert !user_2.admin?

    login(user_1)
    put :update, :id => user_2.id, :user => { :admin => '1' }

    user_2.reload

    assert !user_2.admin?
  end

  test "admin_status_can_be_set_by_admins" do
    admin = FactoryGirl.create(:user)
    admin.make_admin!
    user_2 = FactoryGirl.create(:user)

    assert admin.admin?
    assert !user_2.admin?

    login(admin)
    put :update, :id => user_2.id, :user => { :admin => '1' }

    user_2.reload

    assert user_2.admin?
  end

  test "always_one_admin_left" do
    User.delete_all
    admin = FactoryGirl.create(:user)
    admin.make_admin!
    admin_2 = FactoryGirl.create(:user)
    admin_2.make_admin!
    user = FactoryGirl.create(:user)

    assert_equal 3, User.count

    login(admin)

    # delete the user
    delete :destroy, :id => user.id
    assert_equal 2, User.enabled.count

    # disable the other admin
    post :enable, :id => admin_2.id
    assert_equal 1, User.enabled.count

    # last admin can not be disabled
    post :enable, :id => admin.id
    assert_equal 1, User.enabled.count
  end

  # basic non-exception test
  test "deployments    " do
    user = login

    assert_nothing_raised{
      get :deployments, :id => user
    }

  end

  test "user_can_edit_themselfs" do
    user = login

    get :edit, :id => user.id
    assert_response :success

    post :update, :id => user.id, :user => {:login => 'foobarrr'}
    user.reload
    assert_equal 'foobarrr', user.login
  end

  test "user_not_can_edit_other" do
    user = login
    other = FactoryGirl.create(:user)

    get :edit, :id => other.id
    assert_response :redirect

    post :update, :id => other.id, :user => {:login => 'foobarrr'}
    other.reload
    assert_not_equal 'foobarrr', other.login
  end

  test "enable" do
    user = admin_login
    other = FactoryGirl.create(:user)
    other.disable!

    post :enable, :id => other.id
    assert_response :redirect

    other.reload
    assert !other.disabled?
  end

  test "enable_only_admin" do
    user = login
    other = FactoryGirl.create(:user)
    other.disable!

    post :enable, :id => other.id
    assert_response :redirect

    other.reload
    assert other.disabled?
  end

  test "should_logout_if_disabled_after_login" do
    user = login

    user.disable!

    get :index
    assert_response :redirect
    assert_redirected_to root_path
  end

private

  def create_user(options = {})
    options = ({ :login => 'quire', :email => 'quire@example.com',
      :password => 'quire!', :password_confirmation => 'quire!' }.merge(options))
    post :create, :user => options
  end

end
