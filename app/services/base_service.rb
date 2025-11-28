class BaseService
  def self.call(**args)
    new(**args).call
  end

  def initialize **args
    @params = args.to_h.symbolize_keys
  end

  private

  attr_reader :params
end
