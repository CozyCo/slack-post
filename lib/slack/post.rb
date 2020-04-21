require 'slack/post/version'
require 'net/http'
require 'net/https'
require 'uri'
require 'yajl'

module Slack
	module Post

		DefaultOpts = {
			:channel => '#general'
		}.freeze

		def self.post_with_attachments(message, attachments, chan = nil, opts = {})
			fail "Slack::Post.configure was not called or configuration was invalid" unless configured?(chan)
			pkt = {
				:channel => chan || config[:channel],
				:text => message
			}
			if config[:username]
				pkt[:username] = config[:username]
			end
			if opts.key?(:icon_url) || config.key?(:icon_url)
				pkt[:icon_url] = opts[:icon_url] || config[:icon_url]
			end
			if opts.key?(:icon_emoji) || config.key?(:icon_emoji)
				pkt[:icon_emoji] = opts[:icon_emoji] || config[:icon_emoji]
			end
			if attachments.instance_of?(Array) && attachments != []
				pkt[:attachments] = attachments.map { |a| validated_attachment(a) }
			end
			uri = URI.parse(post_url)

			http = Net::HTTP.new(uri.host, uri.port, config[:proxy_host], config[:proxy_port])
			http.use_ssl = true
			http.ssl_version = :TLSv1_2
			http.verify_mode = OpenSSL::SSL::VERIFY_PEER
			req = Net::HTTP::Post.new(uri.request_uri)
			req.body = Yajl::Encoder.encode(pkt)
			req["Content-Type"] = 'application/json'
			resp = http.request(req)
			case resp
				when Net::HTTPSuccess
					return true
				else
					fail "Received a #{resp.code} response while trying to post. Response body: #{resp.body}"
			end
		end

		def self.validated_attachment(attachment)
			valid_attachment = prune(symbolize_keys(attachment), AttachmentParams)
			if attachment.key?(:fields)
				valid_attachment[:fields] = attachment[:fields].map { |h| prune(symbolize_keys(h), FieldParams) }
			end
			return valid_attachment
		end

		def self.post(message, chan = nil, opts = {})
			post_with_attachments(message, [], chan, opts)
		end

		def self.post_url
			config[:webhook_url] || "https://#{config[:subdomain]}.slack.com/services/hooks/incoming-webhook?token=#{config[:token]}"
		end

		LegacyConfigParams = [:subdomain, :token].freeze

		def self.configured?(channel_was_overriden = false)
			# if a channel was not manually specified, then we must have a channel option in the config OR
			# we must be using the webhook_url which provided its own default channel on the Slack-side config.
			return false if !channel_was_overriden && !config[:channel] && !config[:webhook_url]

			# we need _either_ a webhook url or all LegacyConfigParams
			return true if config[:webhook_url]
			LegacyConfigParams.all? do |parm|
				config[parm]
			end
		end

		def self.config
			@config ||= {}
		end

		def self.configure(opts)
			@config = config.merge(prune(opts))

			# If a channel has not been configured, add the default channel
			# unless we are using a webhook_url, which provides its own default channel.
			@config.merge!(DefaultOpts) unless @config[:webhook_url] || @config[:channel]
		end

		KnownConfigParams = [:webhook_url, :username, :channel, :subdomain, :token, :icon_url, :icon_emoji, :proxy_host, :proxy_port].freeze
		AttachmentParams = [:fallback, :title, :title_link, :author_name, :author_link, :author_icon, :image_url, :thumb_url, :text, :pretext, :color, :fields, :footer, :footer_icon, :ts, :mrkdwn_in].freeze
		FieldParams = [:title, :value, :short].freeze

		def self.prune(opts, allowed_elements = KnownConfigParams)
			opts.inject({}) do |acc, (k, v)|
				k = k.to_sym
				if allowed_elements.include?(k)
					acc[k] = v
				end
				acc
			end
		end

		def self.symbolize_keys(hash)
			return hash.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo }
		end

	end
end
