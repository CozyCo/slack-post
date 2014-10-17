# Slack::Post

Just a simple thing to post messages to your [Slack](http://slack.com) rooms.

## Installation

Add this line to your application's Gemfile:

    gem 'slack-post'

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
Slack::Post.post "Domo arigato.", '#general'
```

### Attachments

slack-post supports message attachments per Slack's [Attachment](https://api.slack.com/docs/attachments) specification.

Use `Slack::Post.post_with_attachments` to send a message with any number of attachments:
```ruby
attachments = [
  {
      fallback: "Required text summary...",
      text: "Optional text that should appear within the attachment",
      pretext: "Optional text that should appear above the formatted data",
      color: "#36a64f",
      fields: [
          {
              title: "Required Field Title",
              value: "Text value of the field.",
              short: false
          }
      ]
  }
]

Slack::Post.post_with_attachments "Domo arigato.", attachments, '#general'
```

### slack-post Command

slack-post comes with a `slack-post` command so you can send messages from the command line:

```sh
$ slack-post
Missing options: subdomain, message
Usage: slack-post [options]
    -s, --subdomain [SUBDOMAIN]      Your slack subdomain
    -m, --message [MESSAGE]          Your message
    -r, --room [ROOM]                The slack room where the message should go (without '#', default 'general')
    -u, --username [USERNAME]        The username, default 'slackbot'
    -f, --config-file [CONFIGFILE]   The configuration file with token or set SLACK_TOKEN environment variable

$ SLACK_TOKEN="1asbcdsdfpoiej2" slack-post -s foo -r random -m "line1\nline2"
```

If SLACK_TOKEN isn't set, slack-post tries to read it from ~/.slack.conf or from the file defined with `--config-file`. 
```sh
$ cat ~/.slack.conf
token: "1asbcdsdfpoiej2"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
