# Posts with comments 

This is a guide, using Rails 8, about how to attach comments to posts. Can be used 
for any nested resource, but this is a useful example.

## 1. Create Post model

```bash
rails generate model Post title content #etc
```

## 2. Create Comment model

```bash
rails generate model Comment name content #etc
```

## 3. Connect them

```ruby
# /apps/models/post.rb
has_many :comments
```

```ruby
# apps/models/comment.rb
belongs_to :post, dependent: :destroy
```

Add the migration:

```bash
rails g migration AddCommentToPost post:references 
```

Run the migration:

```bash 
rails db:migrate
```

## 4. Route them:

```ruby
# Routes.rb
resources :posts do 
  resources :comments, only: [:create, :destroy] # Only admin can destroy 
end
```

## 5. Update show.html.erb to show comments
    
```erb
# /app/views/posts/show.html.erb

    # Display the post
    <h1>@post.title</h1>
    <p>@post.content</p>
    
    # Display the post's comments
    <hr />
    <h1>Comments</h1>
    <% @post.comments.each do |comment| %>
        <%= comment.name %>: <%= comment.content %>
        <br />Posted: <%= comment.created_at.strftime("%d %B %Y") %>
    <% end %>
```

## 6. Update show.html.erb to create

```erb
# /apps/views/posts/show.html.erb
<div id="new-comment">
  <%= form_with model: [@post, @post.comments.build] do |form| %>
    <%= form.label :name %>
    <%= form.text_field :name %>

    <%= form.label :content %>
    <%= form.text_area :content %>

    <%= form.submit %>
  <% end %>
</div>
```

## 7. Update CommentsController

To get the create action to work, add this to the CommentsController so that 
it can reference the @post it will belong to.

```ruby 
class CommentsController < ApplicationController 
  def create 
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(comment_params)
    redirect_to post_path(@post)
  end

  private 
    def comment_params 
      params.expect(comment: [:name, :content])
    end
end
```

Now you can see and post comments on a post.

## 8. Add is_admin? and let them destroy posts

Add something like in the @post.comments.each block:

```erb
<%= link_to "Delete comment", destroy_post_comment_path if is_admin? %>
```

This way, users can create comments, but can't delete them.

## Conclusion

- Create post model
- Create comment model 
- Link them at the level of model
- Create a migration that uses post:references 
- Nest resources in routes.rb
- Build the show / create comment code inside posts/show.html.erb
- Let the admin delete, etc.