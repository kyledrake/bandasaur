# We don't need a fancy logger here (yet).
class SimpleLog
  def initialize(io=STDOUT, disabled=false) @@io = io and @@disabled = disabled end
  def disable; @@disabled = true end
  def enable; @@disabled = false end
  def print(val); write val end
  def puts(val); print "#{val}\n" end
  private
  def write(val); @@io.write(val) unless @@disabled end
end