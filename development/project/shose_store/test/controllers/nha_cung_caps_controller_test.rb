require 'test_helper'

class NhaCungCapsControllerTest < ActionController::TestCase
  setup do
    @nha_cung_cap = nha_cung_caps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nha_cung_caps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nha_cung_cap" do
    assert_difference('NhaCungCap.count') do
      post :create, nha_cung_cap: { dia_chi: @nha_cung_cap.dia_chi, email: @nha_cung_cap.email, so_dien_thoai: @nha_cung_cap.so_dien_thoai, ten: @nha_cung_cap.ten }
    end

    assert_redirected_to nha_cung_cap_path(assigns(:nha_cung_cap))
  end

  test "should show nha_cung_cap" do
    get :show, id: @nha_cung_cap
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nha_cung_cap
    assert_response :success
  end

  test "should update nha_cung_cap" do
    patch :update, id: @nha_cung_cap, nha_cung_cap: { dia_chi: @nha_cung_cap.dia_chi, email: @nha_cung_cap.email, so_dien_thoai: @nha_cung_cap.so_dien_thoai, ten: @nha_cung_cap.ten }
    assert_redirected_to nha_cung_cap_path(assigns(:nha_cung_cap))
  end

  test "should destroy nha_cung_cap" do
    assert_difference('NhaCungCap.count', -1) do
      delete :destroy, id: @nha_cung_cap
    end

    assert_redirected_to nha_cung_caps_path
  end
end
