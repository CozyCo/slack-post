# Slack::Post

Just a simple thing to post messages to your [Slack](http://slack.com) rooms.

## Installation

Add this line to your application's Gemfile:

    gem 'slack-post', git: "git@github.com:CozyCo/slack-post.git", branch: "release"

And then execute:

    $ bundle install

## Usage

Example:
```ruby
require 'slack/post'
Slack::Post.configure(
  subdomain: 'myslack',
  token: 'abc1234567890def',
  username: 'roboto, mr.'
)
Slack::Post.post "Domo arrigato.", '#general'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
