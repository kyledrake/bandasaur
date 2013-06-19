module Helpers
  def title(text=nil)
    text.nil? ? @_title : @_title = text
  end
  
  def require_javascript
    Dir.glob("#{settings.public}/js/*.js").sort!.collect! {|f|
      %{<script type="text/javascript" src="/js/#{File.basename f}"></script>}
    }.join("\n")
  end
  
  def checked_if_exists(ids, id)
    ids.respond_to?(:include?) && ids.include?(id.to_s) ? 'checked' : ''
  end
  
  def h(text)
    raise 'You switched to auto escape, remember?'
    Rack::Utils.escape_html text
  end
  
  def onclick_delete(msg='Are you sure?')
    %{ if (confirm('#{msg}')) { 
         var f = document.createElement('form'); 
         f.style.display = 'none'; 
         this.parentNode.appendChild(f); 
         f.method = 'POST';
         f.action = this.href;
         var m = document.createElement('input'); 
         m.setAttribute('type', 'hidden'); 
         m.setAttribute('name', '_method'); 
         m.setAttribute('value', 'delete'); 
         f.appendChild(m);f.submit(); 
       };
       return false; 
     }
  end
  
  def onclick_put
    %{ var f = document.createElement('form'); 
       f.style.display = 'none'; 
       this.parentNode.appendChild(f); 
       f.method = 'POST'; 
       f.action = this.href;
       var m = document.createElement('input'); 
       m.setAttribute('type', 'hidden'); 
       m.setAttribute('name', '_method'); 
       m.setAttribute('value', 'put'); 
       f.appendChild(m);
       f.submit(); 
       return false;
      }
  end
end