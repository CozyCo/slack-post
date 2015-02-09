require 'net/http'
require 'net/https'
require 'uri'
require 'yajl'

module Slack
	module Post
		
		DefaultOpts = {
			channel: '#general'
		}.freeze
		
		def self.post_with_attachments(message,attachments,chan=nil,opts={})
			raise "You need to call Slack::Post.configure before trying to send messages." unless configured?(chan.nil?)
			pkt = {
				channel: chan || config[:channel],
				text: message,
			}
			if config[:username]
				pkt[:username] = config[:username]
			end
			if opts.has_key?(:icon_url) or config.has_key?(:icon_url)
				pkt[:icon_url] = opts[:icon_url] || config[:icon_url]
			end
			if opts.has_key?(:icon_emoji) or config.has_key?(:icon_emoji)
				pkt[:icon_emoji] = opts[:icon_emoji] || config[:icon_emoji]
			end
			if attachments.instance_of?(Array) && attachments != []
				pkt[:attachments] = attachments.map { |a| validated_attachment(a) }
			end
			uri = URI.parse(post_url)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.ssl_version = :TLSv1
			http.verify_mode = OpenSSL::SSL::VERIFY_PEER
			req = Net::HTTP::Post.new(uri.request_uri)
			req.body = Yajl::Encoder.encode(pkt)
			req["Content-Type"] = 'application/json'
			resp = http.request(req)
			case resp
				when Net::HTTPSuccess
					return true
				else
					raise "There was an error while trying to post. Error was: #{resp.body}"
			end
		end

		def self.validated_attachment(attachment)
			valid_attachment = prune(symbolize_keys(attachment), AttachmentParams)
			if attachment.has_key?(:fields)
				valid_attachment[:fields] = attachment[:fields].map { |h| prune(symbolize_keys(h), FieldParams) }
			end
			return valid_attachment
		end

		def self.post(message,chan=nil,opts={})
			post_with_attachments(message, [], chan, opts)
		end
		
		def self.post_url
			"https://#{config[:subdomain]}.slack.com/services/hooks/incoming-webhook?token=#{config[:token]}"
		end
		
		NecessaryConfigParams = [:subdomain,:token].freeze
		
		def self.configured?(needs_channel=true)
			return false if needs_channel and !config[:channel]
			NecessaryConfigParams.all? do |parm|
				config[parm]
			end
		end
		
		def self.config
			@config ||= DefaultOpts
		end
		
		def self.configure(opts)
			@config = config.merge(prune(opts))
		end
		
		KnownConfigParams = [:username,:channel,:subdomain,:token,:icon_url,:icon_emoji].freeze
		AttachmentParams = [:fallback,:text,:pretext,:color,:fields].freeze
		FieldParams = [:title,:value,:short].freeze
		
		def self.prune(opts, allowed_elements=KnownConfigParams)
			opts.inject({}) do |acc,(k,v)|
				k = k.to_sym
				if allowed_elements.include?(k)
					acc[k] = v
				end
				acc
			end
		end

		def self.symbolize_keys(hash)
			return hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
		end
		
	end
end
