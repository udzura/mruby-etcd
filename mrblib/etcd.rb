module Etcd
  class << self
    def endpoint
      @endpoint ||= "http://127.0.0.1:2379/v2"
    end

    def endpoint=(url)
      @endpoint = url
    end
  end
end
