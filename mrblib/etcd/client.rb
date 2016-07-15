module Etcd
  class Client
    def initialize(endpoint=nil)
      @endpoint = endpoint || Etcd.endpoint
      @httpcli = HttpRequest.new()
    end

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
      url = "#{@endpoint}#{path}"
      res = nil
      case meth
      when :get
        res = @httpcli.get(url, {}, default_get_headers.merge(headers), &b)
      when :post
        res = @httpcli.post(url, default_post_headers.merge(headers), headers)
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
      unless res['node']['dir'] == true
        raise "/keys/#{dir} is not a directory"
      end
      if raw
        res
      else
        res['node']['nodes']
      end
    end

    def put(key, value, options={})
      do_request("/keys/#{key}", :put, {"value" => value}.merge(options))
    end

    def delete(key)
      do_request("/keys/#{key}", :delete)
    end

    def wait(key)
      chunk = nil
      res = @httpcli.get("#{@endpoint}/keys/#{key}?wait=true", {}, default_get_headers) do |data|
        chunk = SimpleHttp::SimpleHttpResponse.new(data)
      end
      if res && chunk
        JSON.parse(chunk.body)
      else
        raise "Something is wrong when long-polling"
      end
    end

    def current_leader
      do_request("/stats/leader", :get)
    end

    def stats
      do_request("/stats/self", :get)
    end
  end
end
