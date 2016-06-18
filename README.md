# Public Library Lab

Your goal is to build an advanced public library application in Ruby on Rails.

![snape](https://media.giphy.com/media/jNcu2YunWZBcI/giphy.gif)

By the end of this lab you will have:

* Basic-Auth: Login, Signup, Logout
* Basic views for your users
* A Many-to-Many database relationship: Users, Libraries, Library Users
* "Skinny", Refactored controllers

### Setup

Create a new rails app:

<details>
```bash
rails new lib_app -T -B -d postgresql
cd lib_app
bundle
```
</details>

Create the databases:
<details>
``` bash
rake db:create
```
</details>


### Models In Review

Let's start by generating a `user` model.

<details>
```bash
rails g model user email:string first_name:string last_name:string password_digest:string
```
</details>


Then go ahead and verify that the migration looks correct:

`db/migrate/*_create_users.rb`

<details>
```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :password_digest

      t.timestamps null: false
    end
  end
end
```
</details>


And it does! Whoot! We're ready to migrate!

<details>
```bash
rake db:migrate
```
</details>


## Routes First

Then all we have to do is create the routes for a user.


`config/routes.rb`

<details>
```ruby
Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"

end
```
</details>


We can look at how these routes are interpreted by Rails.


```bash
rake routes
```



Which gives us the following routes:

```bash
Prefix Verb URI Pattern      Controller#Action
  root GET  /                users#index
 users GET  /users(.:format) users#index
```

Note the special `Prefix` column this will be of great use later.


**What to do next?** The truth is we don't have a `users#index`. We don't even have a `UsersController`. Let's practice using our `rails generate` skills.

<details>
```bash
rails g controller users
```
</details>


This does something like the following:

```bash
***   create  app/controllers/users_controller.rb
      invoke  erb
***   create    app/views/users
      invoke  helper
 **   create    app/helpers/users_helper.rb
      invoke  assets
      invoke    coffee
 **    create      app/assets/javascripts/users.coffee
      invoke    scss
 **   create      app/assets/stylesheets/users.scss
```

Note the special `create` statements here. The `***` ones are the most important. It creates the `users_controller.rb` file and the `views/users` directory.

Now that we have a `users_controller.rb` we should add our `users#index` method.

<details>
```ruby
class UsersController < ApplicationController

  # grab the users
  def index
    @users = User.all
    render :index
  end

end
```
</details>


Then we need to actually create an `index.html.erb`:

<details>
```bash
touch app/views/users/index.html.erb
```
</details>


Then we can go ahead and add something special to our `index`:

<details>
```html
<h1>Welcome to Users Index.</h1>

<div>
There are currently <%= @users.length %> signed_up
</div>
```
</details>


It's time to run our server and go to localhost:3000!
Now we should see `0` users signed_up. We should change that!

<details>
```ruby

Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"

  get "/users/new", to: "users#new", as: "new_user"
end
```
</details>


With the following output after we `rake routes`:

```bash
  Prefix Verb URI Pattern          Controller#Action
    root GET  /                    users#index
   users GET  /users(.:format)     users#index
new_user GET  /users/new(.:format) users#new
```

We don't have a `users#new` so let's create one.


<details>
```ruby

class UsersController < ApplicationController

  def new
    # we need to make
    # a new user
    # to pass to the
    # form later
    @user = User.new
    render :new
  end

end

```
</details>


Then we can continue on to creating a `new.html.erb`

<details>
```html


Sign Up

<%= form_for @user do |f| %>
  <div>
    <%= f.text_field :first_name, placeholder: "First Name" %>
  </div>
  <div>
    <%= f.text_field :last_name, placeholder: "Last Name" %>
  </div>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Sign Up" %>
<% end %>
```
</details>


Which renders a form like the following (note the authenticity token):

<details>
```html
<!-- DO NOT COPY THIS CODE -->
Sign Up

<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="5989PH35p43aagbgiuA/C02p8uD6bLmZR+GCLd01lYPmBOSGLNoHMnEGuZXyzHjnTsMvW6h5860tN6CswMsU5A==" />
  <div>
    <input placeholder="First Name" type="text" name="user[first_name]" id="user_first_name" />
  </div>
  <div>
    <input placeholder="Last Name" type="text" name="user[last_name]" id="user_last_name" />
  </div>
  <div>
    <input placeholder="Email" type="text" name="user[email]" id="user_email" />
  </div>
  <div>
    <input placeholder="Password" type="password" name="user[password]" id="user_password" />
  </div>
  <input type="submit" name="commit" value="Sign Up" />
</form>
```
</details>


Note here the correlation between the key we put into `f.text_field` and `name="..."`.

Also note where this form is going

```html
<form class="new_user" id="new_user" action="/users" accept-charset="UTF-8" method="post">
```

It looks like this form is sending `POST /USERS`, (this can be verified by clicking our "Sign Up" button) but we don't have that route so we have to **create** it.


<details>
```ruby
Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"

  get "/users/new", to: "users#new", as: "new_user"

  post "/users", to: "users#create"
end
```
</details>


Then we need to add that method.

<details>
```ruby
class UsersController < ApplicationController

  ...

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)

    redirect_to "/users"
  end

end
```
</details>

Now when you submit the form you get the following error:

```
ActiveRecord::Unknown
AttributeError in UsersController#create

unknown attribute 'password' for User.
```

This is because we only have a `password_digest`. We also haven't setup our application to help users sign up at all. This is a good time to start adding our authentication logic.


Uncomment your `bcrypt` in your `Gemfile`

`Gemfile`


```ruby
...

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

...
```
Run `bundle` and restart your server.

Then we can add `has_secure_password` to our user model application.

<details>
```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```
</details>


Now when we post the form for the user you'll see in your terminal where the server is running that the user is being created. The difference now is the `password_digest` is being properly hashed.

Now we want to add a route to `GET /users/:id`.

<details>
```ruby

Rails.application.routes.draw do
  root to: "users#index"

  get "/users", to: "users#index", as: "users"

  get "/users/new", to: "users#new", as: "new_user"

  post "/users", to: "users#create"

  get "/users/:id", to: "users#show"
end

```
</details>


We want to add a `users#show` page.

<details>
```ruby

class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    render :show
  end

end

```
</details>


Then we need a view to display the users information.

<details>
```html

<div>
  Welcome, <%= @user.first_name %>
</div>

```
</details>


## Users Sign In

Now that we can create a user we need to be able to sign a user in.

Signing and signing out is a concern of a new controller, the sessions controller.


<details>
```
rails g controller sessions
```
</details>


Note this will create both `sessions_controller.rb` and `sessions_helper.rb`.


Now we should use the `session_helper` by adding our own logic to it.


<details>
```ruby

module SessionsHelper

  def login(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def logged_in?
    if current_user == nil
      redirect_to "/sign_in"
    end
  end

  def logout
    @current_user = session[:user_id] = nil
  end

end
```
</details>


These methods will help avoid code bloat when signing in and out. Before we can use the methods though we have to add these methods to the `ApplicationController`.

<details>
```ruby

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper
end

```
</details>



Now, we are ready to continue. Let's add some routes to `sign_in`.


<details>
```ruby

Rails.application.routes.draw do

  ...

  get "/sign_in", to: "sessions#new"

end

```
</details>



Now we need to add the `sessions#new` action to the sessions controller.


<details>
```ruby

class SessionsController < ApplicationController

  def new
    @user = User.new
    render :new
  end

end
```
</details>


Then we need to add a view for the `sessions/new.html.erb`.

<details>
```bash
touch app/views/sessions/new.html.erb
```
</details>


Then very similarly to what we did before for sign up, we create a form for sign in.

<details>
```html

Sign In

<%= form_for @user, url: "/sessions", method: "post" do |f| %>
  <div>
    <%= f.text_field :email, placeholder: "Email" %>
  </div>
  <div>
    <%= f.password_field :password, placeholder: "Password" %>
  </div>
  <%= f.submit "Sign In" %>
<% end %>

```
</details>


Before we go forward let's go ahead and drop in a very key piece of confirmation logic into our `user` model.

<details>
```ruby
class User < ActiveRecord::Base
  has_secure_password

  def self.confirm(params)
    @user = User.find_by({email: params[:email]})
    @user.try(:authenticate, params[:password])
  end
end
```
</details>


Note that the form is getting submited to `POST /sessions`. We don't have a `sessions#create` however or a route to handle the post.

<details>
```ruby

Rails.application.routes.draw do

  get "/sign_in", to: "sessions#new"

  post "/sessions", to: "sessions#create"

end
```
</details>


Now let's add the `sessions#create`

<details>
```ruby

class SessionsController < ApplicationController

  def create
    user_params = params.require(:user).permit(:email, :password)
    @user = User.confirm(user_params)
    if @user
      login(@user)
      redirect_to "/users/#{@user.id}"
    else
      redirect_to "/sign_in"
    end
  end
end
```
</details>



Then when we try to login let's see what happens. Do you see a welcome? If so you're ready to continue otherwise you should start the long work of debugging.
BONUS: refactor to add validations for log in 

### Finishing Sign Up

After a user is signed up they should be logged in.

<details>
```ruby

class UsersController < ApplicationController

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)
    login(@user) # <-- login the user
    redirect_to "/users/#{@user.id}" # <-- go to show
  end

end

```
</details>


## A Library Model

Let's add our second model, a `Library` model that will later have books.

<details>
```bash
rails g model library name:string floor_count:integer floor_area:integer
```
</details>


We want a `user` to be able to join a library, but this means a `m:n` relationship. A user will have many libraries and library will have many users.

Thus we need a `library_user` model.


<details>
```ruby
rails g model library_user user:references library:references
```
</details>


In the future we can store other things on the `library_user` model that are relevant to someone's membership to a library.

We will also need two different controllers for each of these models. Let's start by being able to do CRUD with Libraries.

<details>
```
rails g controller libraries
```
</details>


And don't forget to migrate your new library models!

<details>
```
rake db:migrate
```
</details>


### A Library Index

Let's add a route to be able to view all the libraries.

<details>
```ruby

Rails.application.routes.draw do
  ...
  get "/libraries", to: "libraries#index"
end
```
</details>


Then we need to add a `libraries#index` method to our libraries controller.

<details>
```ruby

class LibrariesController < ApplicationController

  def index
    @libraries = Library.all

    render :index
  end

end
```
</details>


Finally we can add a basic view for all libraries.


<details>
```html
<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
  </div>
  <br>
<% end %>
```
</details>


### A New Library

To be able to add a new library we need a `libraries#new`.

<details>
```ruby

Rails.application.routes.draw do
...
  get "/libraries/new", to: "libraries#new", as: "new_library"
end

```
</details>


Then we add a `libraries#new` method.


<details>
```ruby
class LibrariesController < ApplicationController
...
  def new
    @library = Library.new

    render :new
  end
end
```
</details>


Finally, we can add a view for `new` library.

<details>
```html

<%= form_for @library do |f| %>
  <div>
    <%= f.text_field :name, placeholder: "Name" %>
  </div>
  <div>
    <%= f.number_field :floor_count, placeholder: "Floor Count" %>
  </div>
  <div>
    <%= f.number_field :floor_area, placeholder: "Floor Area" %>
  </div>
  <%= f.submit %>
<% end %>
```
</details>


This form has nowhere to go. If we try to submit it we get an error because there is no `POST /libraries` route.

Let's add one.


<details>
```ruby

Rails.application.routes.draw do
...
  post "/libraries", to: "libraries#create"
end
```
</details>


Then we need a corresponding `libraries#create`.

<details>
```ruby

class LibrariesController < ApplicationController

  def create
    library_params = params.require(:library).permit(:name, :floor_count, :floor_area)
    @library = Library.create(library_params)

    redirect_to "/libraries"
  end
end
```
</details>


## Joining A Library

We now have the ability to view all libraries, and it will be up to you to create methods to `edit`, `update`, `show`, and `delete` a `library`.

Before we get started joining a `library` and a `user` we need to wire together our `Library` and our `User` via associations.

<details>
```ruby
class User < ActiveRecord::Base
  has_many :library_users
  has_many :libraries, through: :library_users

  ...
end
```
</details>

And we do something similar for a Library.

<details>
```ruby
class Library < ActiveRecord::Base
  has_many :library_users
  has_many :users, through: :library_users
end
```
</details>


But notice here that both models are connected through our `library_users` model. Hence we need to make sure that model knows it belongs to both of those.


<details>
```ruby
class LibraryUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :library
end
```
</details>


You should now test this out in the console.

<details>
```bash
> user = User.first
> user.libraries
#=> []
> sfpl = Library.create({name: "SFPL"}) # San Francisco Public Library
> sfpl.users
#=> []
> sfpl.users.push(user)
> sfpl.users
#=> [ <#User ... @id=1> ]
> LibraryUser.count
#=> 1
> user = User.first
> user.libraries
#=> [ <#Library ... @name="SFPL" @id=1> ]
```
</details>

Joining a library from our web application requires creating a `library_users` controller

<details>
```bash
rails g controller library_users
```
</details>


We want to be able to view all user memberships to a library. We can specify this as a url like `/users/:user_id/libraries`.

<details>
```ruby

Rails.application.routes.draw do
  ...
  get "/users/:user_id/libraries", to: "library_users#index", as: "user_libraries"

end
```
</details>


We also neeed the corresponding `index` method in the `library_users` controller


<details>
```ruby
class LibraryUsersController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    @libraries = @user.libraries

    render :index
  end
end
```
</details>


Then we can have the libraries index render the user and the libraries:


<details>
```html

<div><%= @user.first_name %> is a member of the following libraries</div>

<ul>
  <% @libraries.each do |lib| %>
    <li><%= lib.name %></li>
  <% end %>
</ul>
```
</details>


We can test this by going to `localhost:/users/1/libraries`.


## Add A User Lib

So now that we can view which libraries a `user` has joined, we can go ahead and make a button that allows a user to `join` a library. BONUS: only show the join button if the current user hasn't joined that library yet! (hint: try using `exclude?`)


Let's go back to `libraries#index` and add a button to do just that.


<details>
```html

<% @libraries.each do |library| %>
  <div>
    <h3><%= library.name %></h3>
    <% if @current_user %>
      <%= button_to "Join", library_users_path(library) %>
    <% end %>
  </div>
  <br>
<% end %>
```
</details>

We will have to define `library_user_path` to `POST /libraries/:library_id/users` later. But first we need to update the `library#index` method.

<details>
```ruby
class LibraryUsersController < ApplicationController

  def index
    @libraries = Library.all
    current_user # sets @current_user

    render :index
  end

  ...

end
```
</details>


Of course we now realize we don't have a `POST /libraries/:library_id/users` path, so we need to add one.


<details>
```ruby
Rails.application.routes.draw do
  ...
  get "/users/:user_id/libraries", to: "library_users#index", as: "user_libraries"
  post "/libraries/:library_id/users", to: "library_users#create", as: "library_users"
end

```
</details>


Then we need to add the `create` method to the `library_users` controller.


<details>
```ruby
class LibraryUsersController < ApplicationController

  ...

  def create
    @user = current_user
    @library = Library.find(params[:library_id])
    @user.libraries.push(@library)

    redirect_to user_libraries(@user)
  end
end

```
</details>



## Clean Up

Let's say that in order to visit a `users#show` page you have to be logged in. Then we can add a special `before_action` to check this.

<details>
```ruby
class UsersController < ApplicationController

  before_action :logged_in?, only: [:show]

  ...

  def show
    @user = User.find(params[:id])
    render :show
  end

end
```
</details>


### Exercise

1. Make it so a user has to be `logged_in?` before viewing any of the `LibrariesController` actions or the `LibraryUsers` actions.

2. Modify exercise one such that anyone can view `libraries#index`, but cannot `create` or view `new` without being logged in.


## Refactoring Params

Every time we take in a lot of params in a controller it's tedious to write out.

<details>
```ruby
class UsersController < ApplicationController

  ...

  def create
    user_params = params.require(:user).permit(:first_name, :last_name, :email, :password)
    @user = User.create(user_params)
    login(@user)
    redirect_to "/users/#{@user.id}"
  end

  ...

end

```
</details>



You can utilize a private method for doing this. Let's refactor.


<details>
```ruby
class UsersController < ApplicationController

  ...

  def create
    @user = User.create(user_params) # calls user_params method
    login(@user)
    redirect_to "/users/#{@user.id}"
  end

  ...

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end

```
</details>


### Exercise

* Private methods like `user_params` are simple to implement and give us cleaner looking code. Rewrite `libraries#create` using this idea.

### Bonuses

* Can you add books to the application?
    - For starters, just create a `Book` model and the associated views.
* Can you add books to the library?
    - What kind of a relationship is that? Where would foreign keys like `book_id` and `library_id` live in your database tables?

Solution [here](https://github.com/awhit012/lib-app)
