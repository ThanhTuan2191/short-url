class BaseService
  def self.call(**args)
    new(**args).call
  end

  def initialize **args
    @params = args
  end
end
