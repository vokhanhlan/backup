require 'test_helper'

class LoaiSanPhamsControllerTest < ActionController::TestCase
  setup do
    @loai_san_pham = loai_san_phams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:loai_san_phams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create loai_san_pham" do
    assert_difference('LoaiSanPham.count') do
      post :create, loai_san_pham: { ,: @loai_san_pham.,, ma_loai_cha: @loai_san_pham.ma_loai_cha, ten: @loai_san_pham.ten }
    end

    assert_redirected_to loai_san_pham_path(assigns(:loai_san_pham))
  end

  test "should show loai_san_pham" do
    get :show, id: @loai_san_pham
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @loai_san_pham
    assert_response :success
  end

  test "should update loai_san_pham" do
    patch :update, id: @loai_san_pham, loai_san_pham: { ,: @loai_san_pham.,, ma_loai_cha: @loai_san_pham.ma_loai_cha, ten: @loai_san_pham.ten }
    assert_redirected_to loai_san_pham_path(assigns(:loai_san_pham))
  end

  test "should destroy loai_san_pham" do
    assert_difference('LoaiSanPham.count', -1) do
      delete :destroy, id: @loai_san_pham
    end

    assert_redirected_to loai_san_phams_path
  end
end
