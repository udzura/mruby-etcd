module Etcd
  class Client
    def initialize(endpoint=nil)
      @endpoint = endpoint || Etcd.endpoint
      @httpcli = HttpRequest.new()
    end
    attr_reader :endpoint

    def default_get_headers
      @default_headers ||= {
        'User-Agent' => 'mruby-etcd',
      }
    end

    def default_post_headers
      @default_post_headers ||= {
        'User-Agent'   => 'mruby-etcd',
        'Content-Type' => 'application/x-www-form-urlencoded',
      }
    end

    def do_request(path, meth=:get, body={}, headers={}, &b)
      url = "#{endpoint}#{path}"
      res = nil
      case meth
      when :get
        res = @httpcli.get(url, {}, default_get_headers.merge(headers), &b)
      when :post
        res = @httpcli.post(url, body, default_post_headers.merge(headers), headers)
      when :put
        res = @httpcli.put(url, body, default_post_headers.merge(headers))
      when :delete
        res = @httpcli.delete(url, default_post_headers.merge(headers))
      else
        raise "Invalid http method: #{meth.inspect}"
      end
      begin
        JSON.parse(res.body)
      rescue
        STDERR.puts("Warn: failed to parse as JSON, returning raw data: #{res.inspect}") if STDERR
        res
      end
    end

    def hash2query(hash, prefix="?")
      prefix + hash.to_a.map{|p| p.join('=') }.join('&')
    end

    def get(key, raw=false)
      res = do_request("/keys/#{key}", :get)
      if res.is_a?(Hash)
        return nil if res["errorCode"] == 100
        raw ? res : res['node']['value']
      else
        res
      end
    end

    def list(dir, raw=false)
      res = do_request("/keys/#{dir}", :get)
      unless res.is_a?(Hash)
        raise "Something is wrong with /keys/#{dir}: #{res.inspect}"
      end
      if !res["errorCode"] and !res['node']['dir']
        raise "/keys/#{dir} is not a directory"
      end
      if raw
        res
      else
        return [] if res["errorCode"] == 100
        res['node']['nodes']
      end
    end

    def put(key, value, options={})
      do_request("/keys/#{key}", :put, {"value" => value}.merge(options))
    end

    def delete(key)
      do_request("/keys/#{key}", :delete)
    end

    def wait(key, recursive=false)
      if !recursive and dir?(key)
        raise "Directory TTL is not yet supported, so must be recursive=true when watching directory: /#{key}"
      end
      chunk = nil
      params = recursive ? "wait=true&recursive=true" : "wait=true"
      res = @httpcli.get("#{endpoint}/keys/#{key}?#{params}", {}, default_get_headers) do |data|
        chunk = SimpleHttp::SimpleHttpResponse.new(data)
      end
      if res && chunk
        JSON.parse(chunk.body)
      else
        raise "Something is wrong when long-polling"
      end
    end

    def dir?(key_or_dir)
      target = get(key_or_dir, true)
      !! target["node"]["dir"]
    end

    def members(raw=true)
      res = do_request("/members", :get)
      if raw
        res
      else
        res["members"]
      end
    end

    def add_member(peer_urls=[], raise_on_fail=false)
      url = "#{endpoint}/members"
      headers = default_get_headers.merge({'Content-Type' => 'application/json'})
      body = {"peerURLs" => peer_urls}.to_json
      res = @httpcli.post(url, body, default_post_headers.merge(headers))
      if res.code == 201 or res.code == 200
        JSON.parse(res.body)
      elsif raise_on_fail
        raise "Adding member failed: status=#{res.code}, #{JSON.parse(res.body).inspect}"
      else
        return res
      end
    end

    def delete_member(id)
      do_request("/members/#{id}", :delete)
    end

    def join(peer_api_endpoint, raise_on_fail=false)
      peer = Etcd::Client.new(peer_api_endpoint)
      self_id = stats["id"]
      self_endpoint = members(false).find{|m| m["id"] == self_id }["peerURLs"].first
      peer.add_member([self_endpoint], raise_on_fail)
    end

    def current_leader
      do_request("/stats/leader", :get)
    end

    def stats
      do_request("/stats/self", :get)
    end
  end
end
