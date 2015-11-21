require 'test_helper'

class SanPhamsControllerTest < ActionController::TestCase
  setup do
    @san_pham = san_phams(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:san_phams)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create san_pham" do
    assert_difference('SanPham.count') do
      post :create, san_pham: { datetime: @san_pham.datetime, don_gia: @san_pham.don_gia, ma_loai_san_pham: @san_pham.ma_loai_san_pham, ma_nha_cung_cap: @san_pham.ma_nha_cung_cap, mo_ta: @san_pham.mo_ta, ngay_san_xuat: @san_pham.ngay_san_xuat, san_pham_moi: @san_pham.san_pham_moi, ten: @san_pham.ten, trang_thai: @san_pham.trang_thai }
    end

    assert_redirected_to san_pham_path(assigns(:san_pham))
  end

  test "should show san_pham" do
    get :show, id: @san_pham
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @san_pham
    assert_response :success
  end

  test "should update san_pham" do
    patch :update, id: @san_pham, san_pham: { datetime: @san_pham.datetime, don_gia: @san_pham.don_gia, ma_loai_san_pham: @san_pham.ma_loai_san_pham, ma_nha_cung_cap: @san_pham.ma_nha_cung_cap, mo_ta: @san_pham.mo_ta, ngay_san_xuat: @san_pham.ngay_san_xuat, san_pham_moi: @san_pham.san_pham_moi, ten: @san_pham.ten, trang_thai: @san_pham.trang_thai }
    assert_redirected_to san_pham_path(assigns(:san_pham))
  end

  test "should destroy san_pham" do
    assert_difference('SanPham.count', -1) do
      delete :destroy, id: @san_pham
    end

    assert_redirected_to san_phams_path
  end
end
