class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  private_class_method :new

  def success(data = nil)
    ApplicationServiceResult.new(success: true, data: data)
  end

  def failure(message)
    ApplicationServiceResult.new(success: false, error: message)
  end
end
