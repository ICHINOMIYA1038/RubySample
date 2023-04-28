# Strong Parameters
マスアサインメントと呼ばれるテクニックで、Railsアプリケーションでよく使われます。

RailsにおけるDBの更新系処理で複数のカラムを一括で指定できる機能の事。
例えば

Person.new(name: 'nakamura', age: 29)
といったように複数のカラムを一気に保存できる。便利な機能。

この内容をそのままにマスアサインメント機能を利用して設定していた場合に、
想定していないカラムを更新されてしまう可能性があります。

例えばUserクラスに name, age, admin の3カラムがあり、
adminはユーザーの画面からは更新させない管理者権限だとします。

```js
user = User.new(params[:user])
user.save
```

悪意あるユーザーがroleにadminという値を設定してリクエストを送ってきた場合(不正リクエスト)、意図せず管理者ユーザーを作られてしまう可能性がある。

それを防ぐためにストロングパラメータという機能がある。

これは、あらかじめ設定可能な値を明示的に宣言しておくことで脆弱性を回避できるようになる。

以前のバージョンのRailsでは、この妨害をattr_accessibleメソッドをモデル層で使うことで上記のような危険を防止していた。

Rails4.0では、Strong Parametersというテクニックをコントローラ層で使うことが推奨されています。

Strong Parametersでは、必須パラメータと許可済みパラメータを指定できます。

例えば、paramsハッシュでは:user属性を必須として、名前、メールアドレス、パスワード、パスワードの確認の属性をそれぞれ許可し、それ以外は許可しないようにしたいと思います。


```rb
params.require(:user).permit(:name,:email,:password,:password_confirmation)
```

このコードの戻り値は、許可された属性のみが含まれたparamsのハッシュです。

これらのパラメータはuser_paramsのような補助メソッドの形で使うのが定番です。
このメソッドは適切に初期化したハッシュを返し、古いparams[:user]の代わりに次のように使います。

```rb
@user = User.new(user_params)
```

このuser_paramsは、privateのキーワードを使って外部から使えないようにします。

```ruby
class UsersController < ApplicationController
  .
  .
  .
  def create
    @user = User.new(user_params)
    if @user.save
      # 保存の成功をここで扱う。
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
```

## pluralize 
《文法》複数（形）にする

テスト機能を備えた強力なWebフレームワークがなかった時代では、開発者はフォームのテストを毎回手動で行う必要がありました。

```bash
$ rails generate integration_test users_signup
      invoke  test_unit
      create    test/integration/users_signup_test.rb
```

# テストについて
[Rails チュートリアル　【初心者向け】　テストを10分でおさらいしよう！　](https://qiita.com/duka/items/2d724ea2226984cb544f)

単体テスト	モデルやビューヘルパー単体の動作をチェック
機能テスト	コントローラー/ビューの呼び出し結果をチェック
統合テスト	ユーザーの実際の操作を想定し、複数のコントローラーにまたがるアプリの挙動をチェックする



**assert メソッドは、第1引数がtrue である場合に、テストが成功したものとみなします。**
assertメソッドにはそれ以外にも。assert_not,assert_equal,assert_,matchなどがあります。

## 機能テスト
機能テストでは、コントローラーの動作やビューの出力を確認します。
HTTPリクエストを擬似的に作成することで、アクションメソッドを実行し、HTTPステータスやテンプレート変数、最終的な出力の構造までを確認する。
また、ルーティングもチェックします。

asser_respone は指定したHTTPステータスが返されたかを確認する。
success(200)、:redirect(300番台)、:missing(404),:error(500番台)など

assert_redirected_to　リダイレクト先が正しいか。
assert_template(temp,[msg])
assert_select        selectorに合致した要素の内容を引数equalityでチェック

## フラッシュメッセージ
Railsでこういった情報を表示するには、flashという特殊な変数を用います。
この変数はハッシュのように扱います。
Railsの一般的な慣習に沿って、:successというキーには成功時のメッセージを代入するようにします。

```rb
class UsersController < ApplicationController
  .
  .
  .
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
```

:successというキーには成功時のメッセージを代入するようにしましょう。
今回は、flashに存在するキーがあるかを調べ、キーが荒れたbあ、その値を表示するようにレイアウトを修正します。
4.3.3 の時にコンソール上で実行した例を思い出してみてください。
そこであえてflashと名付けた変数を使い、ハッシュの値を列挙しました。

## 成功時のテスト
assert_difference 'User.Count',1 do
で一人追加されたことを検知する。

follow_redirect!というメソッドは、POSTリクエストした結果を確認して、指定したリダイレクト先に移動するメソッドです。

したがって、この行の直後では、'users/show'テンプレートが表示されているはずです。
ちなみに、ここでflashのテストも追加しておくと良いでしょう。

```rb
require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  .
  .
  .
  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?

  end
end
```



