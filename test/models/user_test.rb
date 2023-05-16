require "test_helper"
class UserTest < ActiveSupport::TestCase
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
    # ユーザーは自分自身をフォローできない
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    #フォローしているユーザーの投稿を確認
    lana.microposts.each do|post_following|
      assert michael.feed.include?(post_following)
    end
    #フォロワーがいるユーザー自身の投稿を確認
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end