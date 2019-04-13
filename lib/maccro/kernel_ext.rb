require_relative "./code_util"

module Kernel
  def dirty_require(feature)
    Maccro::CodeUtil.suppress_warning do
      require feature
    end
  end

  def dirty_load(file, priv = false)
    Maccro::CodeUtil.suppress_warning do
      load(file, priv)
    end
  end
end
