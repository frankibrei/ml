classdef Rast2HisOb < handle
    % class to plot raster plot + horizontal and vertical histograms
    
    properties (SetAccess = private, GetAccess = public)
        xlu1;
        ylu1;
        xw1;
        xw2;
        yw1;
        yw3;
        fig;
        plos;   % plot structure 1. Hauptplot: raster dots
        %2. histogram to right
        %3. histogram at bottom
        title;
        subtitle;
        legend1;
        x_legend1;
        y_legend1;
        points_legend1;
        legend2;
        x_legend2;
        y_legend2;
        points_legend2;
        FaceAlpha;% not only lines but area, for transparency
        xmicro;
        ymicro;
        print_png;
    end  % properties
    
    
    
    methods  (Access = private)
        function init(obj)                        
            obj.xmicro=0;
            obj.ymicro=0;
            obj.print_png=1;
            obj.FaceAlpha = 0.3;
            obj.title='';
            obj.subtitle='';
            obj.legend1='';            
            obj.legend2='';            
        end
    end
    
    methods  (Access = public)
        
        function obj = Rast2HisOb()
            obj.init();
            right_margin=0.02;
            top_margin=0.05;
            bottom_margin=0.05;
            obj.xlu1=right_margin;
            
            obj.xw1=0.8;
            obj.yw1=0.6;
            obj.ylu1=1-obj.yw1-top_margin;
            obj.xw2=1-obj.xw1-obj.xlu1-right_margin;
            obj.yw3=obj.ylu1-bottom_margin;
            for i=1:3
                obj.plos(i).ax=0; % handle auf axes object
                obj.plos(i).xlimits=[0 0];
                obj.plos(i).ylimits=[0 0];
                obj.plos(i).nsmooth=0;
                obj.plos(i).nsmooth2=0;
                obj.plos(i).dotcolor=[0.4 0.4 0.4];
                obj.plos(i).binwidth=10;
                obj.plos(i).plotsum=false;
                obj.plos(i).amp_fac=1;
                obj.plos(i).legends=struct([]); % for additional annotations of data etc
                obj.plos(i).nr_of_legends=0;
            end
            obj.plos(1).posvec=[obj.xlu1 obj.ylu1 obj.xw1 obj.yw1]; % Hauptplot: raster dots
            obj.plos(2).posvec=[obj.xlu1+obj.xw1 obj.ylu1 obj.xw2 obj.yw1]; % histogram to right
            obj.plos(3).posvec=[obj.xlu1 obj.ylu1-obj.yw3 obj.xw1 obj.yw3]; % histogram below
            obj.plos(2).binwidth=1;
            obj.plos(3).binwidth=10;
            
        end
        %-------------------------------------------
        function add_legend(obj,nr_plos,x,y,legend)
            obj.plos(nr_plos).nr_of_legends=obj.plos(nr_plos).nr_of_legends+1;
            obj.plos(nr_plos).legends(obj.plos(nr_plos).nr_of_legends).x=x;
            obj.plos(nr_plos).legends(obj.plos(nr_plos).nr_of_legends).y=y;
            obj.plos(nr_plos).legends(obj.plos(nr_plos).nr_of_legends).legend=legend;
        end
        %-------------------------------------------
        function set_color(obj,nr_plos,colorvek)
            obj.plos(nr_plos).dotcolor=colorvek;
        end
        %-------------------------------------------
        function set_binwidth(obj,nr_plos,binwidth)
            obj.plos(nr_plos).binwidth=binwidth;
        end
         %-------------------------------------------
         function set_xlimits(obj,nr_plos,xmin,xmax)
             if ~isempty(xmin)
                 if ~isempty(xmax)
                     obj.plos(nr_plos).xlimits=[xmin xmax];
                 end
             end
         end
        %-------------------------------------------
        function set_ylimits(obj,nr_plos,ymin,ymax)
            obj.plos(nr_plos).ylimits=[ymin ymax];
        end
        %-------------------------------------------
        function set_plot_sum(obj,nr_plos,value,ampfac)
            obj.plos(nr_plos).plotsum=value;
            obj.plos(nr_plos).amp_fac=ampfac;
        end
        %-------------------------------------------
        function set_title(obj,s_title)
            obj.title=s_title;
        end  
        %-------------------------------------------
        function set_subtitle(obj,s_title)
            obj.subtitle=s_title;
        end  
        %-------------------------------------------
        function set_legend2(obj,x,y,legend,pts)
            obj.legend2=legend;
            obj.x_legend2=x;
            obj.y_legend2=y;
            obj.points_legend2=pts;
        end
        %-------------------------------------------
        function set_legend1(obj,x,y,legend,pts)
            obj.legend1=legend;
            obj.x_legend1=x;
            obj.y_legend1=y;
            obj.points_legend1=pts;
        end
        %-------------------------------------------
        function set_smooth(obj,nr_plos,nsmooth)
            obj.plos(nr_plos).nsmooth=nsmooth;
        end
        %-------------------------------------------
        function set_smooth2(obj,nr_plos,nsmooth)
            obj.plos(nr_plos).nsmooth2=nsmooth;
        end
        %-------------------------------------------
        function h=plot_histo_area1(obj,nr_plos,hisvek)            
            h=0;
            len=length(hisvek);
            if len==0
                return
            end
            xmin=obj.plos(nr_plos).xlimits(1)-1;
            xmax=obj.plos(nr_plos).xlimits(2);
            ymin=obj.plos(nr_plos).ylimits(1);
            ymax=obj.plos(nr_plos).ylimits(2);           
            if obj.plos(nr_plos).nsmooth>0
                if obj.plos(nr_plos).nsmooth>20
                    for is=1:obj.plos(nr_plos).nsmooth-20
                        hisvek=smooth(hisvek,21);
                    end
                elseif obj.plos(nr_plos).nsmooth>10
                    for is=1:obj.plos(nr_plos).nsmooth-10
                        hisvek=smooth(hisvek,11);
                    end
                else
                    for is=1:obj.plos(nr_plos).nsmooth
                        hisvek=smooth(hisvek);
                    end
                end
            end
            hismax=max(hisvek);
            hismin=min(hisvek);
            if (ymin==ymax) % dann tatsächliche Counts, ab 0
                ymin=0;
                ymax=hismax;
                hismin=0;
            end
            binwidth=(xmax-xmin)/len;
            x=zeros(2*len+2,1);
            y=zeros(2*len+2,1);
            lastx=xmin;
            lasty=ymin;
            inx=1;
            x(inx)=lastx;
            y(inx)=lasty;
            for i=1:len
                lasty=ymin+(hisvek(i)-hismin)*(ymax-ymin)/(hismax-hismin); % ymin gehört zu Wert hismin
                inx=inx+1;
                x(inx)=lastx;
                y(inx)=lasty;
                inx=inx+1;
                lastx=lastx+binwidth;
                x(inx)=lastx;
                y(inx)=lasty;
            end
            inx=inx+1;
            x(inx)=lastx;
            y(inx)=ymin;
            
            h=patch(x+obj.xmicro,y+obj.ymicro, obj.plos(nr_plos).dotcolor, 'FaceAlpha', obj.FaceAlpha);
            set(h,'EdgeColor',obj.plos(nr_plos).dotcolor);
           
        end
        %-------------------------------------------
        function h=plot_histo_area(obj,nr_plos,hisvek)
            
            if obj.plos(nr_plos).nsmooth2>0 % plot first more smoothed less color
                nsmooth_save=obj.plos(nr_plos).nsmooth;
                obj.plos(nr_plos).nsmooth=obj.plos(nr_plos).nsmooth2;
                dotcolorsave=obj.plos(nr_plos).dotcolor;
                obj.plos(nr_plos).dotcolor=obj.plos(nr_plos).dotcolor*1.6;
                for i=1:length(obj.plos(nr_plos).dotcolor)
                    if obj.plos(nr_plos).dotcolor(i)>1
                        obj.plos(nr_plos).dotcolor(i)=1;
                    end
                end
                h=plot_histo_area1(obj,nr_plos,hisvek);
                obj.plos(nr_plos).nsmooth=nsmooth_save;
                obj.plos(nr_plos).dotcolor=dotcolorsave;
            end
            h=plot_histo_area1(obj,nr_plos,hisvek);
        end
        %-------------------------------------------
        %-------------------------------------------
        function plotini(obj,papertype)
            %fig=figure('PaperSize',[20 30 ],'PaperOrientation','portrait','PaperPosition', [0.5 0.5  20.0 30.0]);
            if isempty(papertype)
                papertype='a4';
            end
            obj.fig=figure('PaperType','a4','PaperOrientation','portrait');
            set(obj.fig,'position',get(0,'screensize')); % Maximum for screen
        end
         % --------------------------------------------------------------------
        %-------------------------------------------
        function print2file(obj,pdf_folder,fn_part)
        if ~strcmp(pdf_folder,'')  % absoluter Pfad
            OutFN=strcat(fn_part);
            if obj.print_png==1
                pdffn=strcat(pdf_folder,OutFN,'.png');
                print(obj.fig,pdffn,'-dpng','-r200');
            else
                pdffn=strcat(pdf_folder,OutFN,'.pdf');
                print(obj.fig,pdffn,'-dpdf');
            end
        end
        end
       
        %-------------------------------------------
        function plot_xhisto(obj,spike_rows,tspan_ms)
            xmax=max(spike_rows);
            xmin=min(spike_rows);
            if xmin==0
                xmin=xmin+1;
                xmax=xmax+1;
                spike_rows=spike_rows+1;
            end
            if obj.plos(2).xlimits(1)==obj.plos(2).xlimits(2) % calculate from data
                obj.set_xlimits(2,xmin,xmax);
            end
            hisvek=zeros(xmax,1);
            for i=1:length(spike_rows)
                hisvek(spike_rows(i))=hisvek(spike_rows(i))+1;
            end
            hisvek=hisvek*1000/tspan_ms;
            obj.plos(2).ax=axes('position',obj.plos(2).posvec);
            view(90,90);
            obj.plot_histo_area( 2,hisvek);
            axis tight;
            grid on;
        end
        %-------------------------------------------
        function plot_yhisto(obj,spike_times,nr_of_sweeps)
            xmax=max(spike_times);
            xmin=min(spike_times);
            if obj.plos(3).xlimits(1)==obj.plos(3).xlimits(2) % calculate from data
                obj.set_xlimits(3,xmin,xmax);
            end
            nr_of_bins=ceil(max(spike_times)/obj.plos(3).binwidth);
            hisvek=zeros(nr_of_bins,1);
            for i=1:length(spike_times)
                ibin=ceil(spike_times(i)/obj.plos(3).binwidth);
                hisvek(ibin)=hisvek(ibin)+1;
            end
            hisvek=hisvek*1000/(obj.plos(3).binwidth*nr_of_sweeps);
            obj.plos(3).ax=axes('position',obj.plos(3).posvec);
            obj.plot_histo_area( 3,hisvek);
            set(gca,'YAxisLocation','right');
            axis tight;
            grid on;
        end
        %-------------------------------------------
        %         function plot_raster(obj,dotrow_vek,dotcolor,dotlength)
        %             spike_times1=dotrow_vek(1).spike_times;
        %             spike_rows1=dotrow_vek(1).spike_rows;
        %             if ~isempty(spike_times1)
        %                 plot_dots(spike_times1,spike_rows1,dotcolor,dotlength);
        %             end
        %         end
        %-------------------------------------------
        function plot_dots(obj,spike_times,spike_rows,tspan_ms,nr_of_sweeps,dotlength)
            if nr_of_sweeps>0
                ymin=0;
                ymax=nr_of_sweeps;
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);
            else
                ymin=min(spike_rows);
                ymax=max(spike_rows);
            end
            if obj.plos(1).ylimits(1)==obj.plos(1).ylimits(2) % calculate from data
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);
            end
            xx=[];
            yy=[];
            nr_of_trials=length(spike_times);
            for i=1:nr_of_trials
                x=spike_times(i);
                s1=[x,x];
                y1=spike_rows(i);
                y2=y1+dotlength;
                s2=[y2,y1];
                xx=[xx;s1];
                yy=[yy;s2];
            end
            obj.plos(1).ax=axes('position',obj.plos(1).posvec);
            %obj.plos(1).ax.YAxisLocation = 'right';
            plot(xx',yy','color',obj.plos(1).dotcolor);
            axis tight;
            grid on;
            set(gca,'YDir','Reverse');
            set(gca, 'ylim', [obj.plos(1).ylimits(1) obj.plos(1).ylimits(2)]);
            set(gca,'YAxisLocation','right');
            
            %             NrofXTicks(1)=10;
            % %             MinXTickLabel=[0 0 0];
            % %             MaxXTickLabel;
            %             xdist=ceil(maxrow-minrow)/NrofXTicks(1);
            obj.plos(1).ax.XTick = [];
            %obj.h1.XTickLabel ={int2str(obj.h1.XTick)};
        end
        %-------------------------------------------
        %-------------------------------------------
        function plot_xhisto_struct0(obj,spic_struct,tspan_ms) %old
            nr_of_cats=length(spic_struct);
            xmax=0;
            xmin=1;
            for icat=1:nr_of_cats
                spike_rows=cell2mat({spic_struct(icat).spike_rows});
                xmax=max(xmax,max(spike_rows));
                xmin=min(xmin,min(spike_rows));
                if xmin==0
                    xmin=xmin+1;
                    xmax=xmax+1;
                    spike_rows=spike_rows+1;
                    spic_struct(icat).spike_rows=spike_rows;
                end
            end
            if obj.plos(2).xlimits(1)==obj.plos(2).xlimits(2) % calculate from data
                obj.set_xlimits(2,xmin,xmax);
            end
            for icat=1:nr_of_cats
                spike_rows=cell2mat({spic_struct(icat).spike_rows});
                hisvek=zeros(xmax,1);
                for i=1:length(spike_rows)
                    hisvek(spike_rows(i))=hisvek(spike_rows(i))+1;
                end
                hisvek=hisvek*1000/tspan_ms;
                if icat==1
                    obj.plos(2).ax=axes('position',obj.plos(2).posvec);
                    view(90,90);
                end
                obj.set_color(2,obj.get_cat_color(icat));
                obj.plot_histo_area( 2,hisvek);
                axis tight;
                grid on;
                hold on;
            end
        end
        %-------------------------------------------
        function plot_xhisto_struct(obj,spic_struct,tspan_ms,nr_of_sweeps)
            nr_of_cats=length(spic_struct);
            xmax=nr_of_sweeps;
            xmin=0;           
            if obj.plos(2).xlimits(1)==obj.plos(2).xlimits(2) % calculate from data
                obj.set_xlimits(2,xmin,xmax);
            end
            for icat=1:nr_of_cats
                spike_rows=cell2mat({spic_struct(icat).spike_rows});
                hisvek=zeros(xmax,1);
                for i=1:length(spike_rows)
                    hisvek(spike_rows(i))=hisvek(spike_rows(i))+1;
                end
                hisvek=hisvek*1000/tspan_ms;
                if icat==1
                    obj.plos(2).ax=axes('position',obj.plos(2).posvec);
                    view(90,90);
                end
                obj.set_color(2,obj.get_cat_color(icat));
                obj.plot_histo_area( 2,hisvek);
                axis tight;
                grid on;
                hold on;
            end
            % now add legends in yhisto ! x and y axes interchanged !
            for i=1:obj.plos(2).nr_of_legends
                x=obj.plos(2).legends(i).y;
                y=obj.plos(2).legends(i).x;
                legend=obj.plos(2).legends(i).legend;
                text(x,y,legend,'Color','red','FontSize',8,'interpreter','none');
            end
        end
        %-------------------------------------------
        function plot_yhisto_struct(obj,spic_struct,tspan_ms,nr_of_sweeps)
              nr_of_cats=length(spic_struct);
            xmax=0;
            xmin=1;
            for icat=1:nr_of_cats
                spike_times=cell2mat({spic_struct(icat).spike_times});
                xmax=max(xmax,max(spike_times));
                xmin=min(xmin,min(spike_times));
            end
            if obj.plos(3).xlimits(1)==obj.plos(3).xlimits(2) % calculate from data
                obj.set_xlimits(3,xmin,xmax);
            end
            nr_of_bins=ceil(tspan_ms/obj.plos(3).binwidth);
            hisvek_sum=zeros(nr_of_bins,1);
            
            for icat=1:nr_of_cats
                spike_times=cell2mat({spic_struct(icat).spike_times});
                hisvek=zeros(nr_of_bins,1);
                for i=1:length(spike_times)
                    ibin=ceil(spike_times(i)/obj.plos(3).binwidth);
                    hisvek(ibin)=hisvek(ibin)+1;
                end
                hisvek=hisvek*1000/(obj.plos(3).binwidth*spic_struct(icat).nr_of_sweeps);
                hisvek_sum=hisvek_sum+hisvek;
                if icat==1
                    obj.plos(3).ax=axes('position',obj.plos(3).posvec);
                    set(gca,'YAxisLocation','right');
                    axis tight;
                    grid on;
                    hold on;
                end
                obj.set_color(3,obj.get_cat_color(icat));
                obj.plot_histo_area( 3,hisvek);
                
            end
            if obj.plos(3).plotsum==true
                hisvek_sum=hisvek_sum/nr_of_cats*obj.plos(3).amp_fac; % a little bit higher
                obj.set_color(3,[0.8 0.8 0.8 ]); % light grey for sum plot
                obj.plot_histo_area( 3,hisvek_sum);
            end
            
        end       
        %-------------------------------------------
        function plot_yhisto_struct_w(obj,spic_struct,resp_window_ms,nr_of_sweeps)
              nr_of_cats=length(spic_struct);
            xmax=0;
            xmin=1;
            for icat=1:nr_of_cats
                spike_times=cell2mat({spic_struct(icat).spike_times});
                xmax=max(xmax,max(spike_times));
                xmin=min(xmin,min(spike_times));
            end
            obj.set_xlimits(3,resp_window_ms(1),resp_window_ms(2));
            if obj.plos(3).xlimits(1)==obj.plos(3).xlimits(2) % calculate from data
                obj.set_xlimits(3,xmin,xmax);
            end
            tspan_ms=resp_window_ms(2)-resp_window_ms(1);
            nr_of_bins=ceil(tspan_ms/obj.plos(3).binwidth);
            hisvek_sum=zeros(nr_of_bins,1);
            
            for icat=1:nr_of_cats
                % if icat~=3
                    spike_times=cell2mat({spic_struct(icat).spike_times});
                    hisvek=zeros(nr_of_bins,1);
                    for i=1:length(spike_times)
                        ibin=ceil((spike_times(i)-resp_window_ms(1))/obj.plos(3).binwidth);
                        if (ibin>0)&(ibin<=nr_of_bins)
                            hisvek(ibin)=hisvek(ibin)+1;
                        end
                    end
                    hisvek=hisvek*1000/(obj.plos(3).binwidth*spic_struct(icat).nr_of_sweeps);
                    hisvek_sum=hisvek_sum+hisvek;
                    if icat==1
                        obj.plos(3).ax=axes('position',obj.plos(3).posvec);
                        set(gca,'YAxisLocation','right');
                        axis tight;
                        grid on;
                        hold on;
                    end
                    obj.set_color(3,obj.get_cat_color(icat));
                    obj.plot_histo_area( 3,hisvek);
                %end
            end
            if obj.plos(3).plotsum==true
                hisvek_sum=hisvek_sum/nr_of_cats*obj.plos(3).amp_fac; % a little bit higher
                obj.set_color(3,[0.8 0.8 0.8 ]); % light grey for sum plot
                obj.plot_histo_area( 3,hisvek_sum);
            end
            
        end       
        %-------------------------------------------
        function plot_dots_struct(obj,spic_struct,tspan_ms,nr_of_sweeps,dotlength)
            if nr_of_sweeps>0
                ymin=0;
                ymax=nr_of_sweeps;
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);            
            end
            if obj.plos(1).ylimits(1)==obj.plos(1).ylimits(2) % calculate from data
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);
            end
          
            nr_of_cats=length(spic_struct);
            for icat=1:nr_of_cats
                  xx=[];
                  yy=[];
                  spike_times=cell2mat({spic_struct(icat).spike_times});
                  spike_rows=cell2mat({spic_struct(icat).spike_rows});
                  nr_of_trials=length(spike_times);
                  for i=1:nr_of_trials
                      x=spike_times(i);
                      s1=[x,x];
                      y1=spike_rows(i);
                      y2=y1+dotlength;
                      s2=[y2,y1];
                      xx=[xx;s1];
                      yy=[yy;s2];
                  end
                  if icat==1
                      obj.plos(1).ax=axes('position',obj.plos(1).posvec);
                      set(gca,'YDir','Reverse');
                      
                      set(gca, 'ylim', [obj.plos(1).ylimits(1) obj.plos(1).ylimits(2)]);
                      set(gca,'YAxisLocation','right');
                      axis tight;
                      grid on;
                      hold on;
                      
                      obj.plos(1).ax.XTick = [];
                  end
                  plot(xx',yy','color',obj.get_cat_color(icat));                  
            end
        end
        %-------------------------------------------
        function plot_dots_struct_w(obj,spic_struct,resp_window_ms,nr_of_sweeps,dotlength)
            obj.set_xlimits(1,resp_window_ms(1),resp_window_ms(2));
            if nr_of_sweeps>0
                ymin=0;
                ymax=nr_of_sweeps;
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);            
            end
            if obj.plos(1).ylimits(1)==obj.plos(1).ylimits(2) % calculate from data
                obj.set_ylimits(1,ymin,ymax);
                obj.set_xlimits(2,ymin,ymax);
            end
          
            nr_of_cats=length(spic_struct);
            for icat=1:nr_of_cats
                  xx=[];
                  yy=[];
                  spike_times=cell2mat({spic_struct(icat).spike_times});
                  spike_rows=cell2mat({spic_struct(icat).spike_rows});
                  nr_of_trials=length(spike_times);
                  for i=1:nr_of_trials
                      x=spike_times(i);
                      s1=[x,x];
                      y1=spike_rows(i);
                      y2=y1+dotlength;
                      s2=[y2,y1];
                      xx=[xx;s1];
                      yy=[yy;s2];
                  end
                  if icat==1
                      obj.plos(1).ax=axes('position',obj.plos(1).posvec);
                      set(gca,'YDir','Reverse');
                      set(gca,'YAxisLocation','right');
                      
                      set(gca, 'ylim', [obj.plos(1).ylimits(1) obj.plos(1).ylimits(2)]);
                      set(gca, 'xlim', [obj.plos(1).xlimits(1) obj.plos(1).xlimits(2)]);
                      
                      axis tight;
                      grid on;
                      hold on;
                      
                      obj.plos(1).ax.XTick = [];
                  end
                  plot(xx',yy','color',obj.get_cat_color(icat));                  
            end
            set(gca, 'ylim', [obj.plos(1).ylimits(1) obj.plos(1).ylimits(2)]);
            set(gca, 'xlim', [obj.plos(1).xlimits(1) obj.plos(1).xlimits(2)]);

        end        
        %-------------------------------------------
        function plot_all_3(obj,spike_times,spike_rows,tspan_ms,nr_of_sweeps)
            if nr_of_sweeps>0
                nr_of_rows=nr_of_sweeps;
            else
                maxrow=max(spike_rows);
                minrow=min(spike_rows);
                nr_of_rows=maxrow-minrow+1;
            end
            obj.plotini('a4');        
            dotlength=obj.get_dotlength(nr_of_rows);
            obj.plot_xhisto(spike_rows,tspan_ms);
            %
            %             %hold on;
            %
            obj.plot_yhisto(spike_times,nr_of_sweeps);
            obj.plot_dots(spike_times,spike_rows,tspan_ms,nr_of_sweeps,dotlength);
            title(obj.title,'Interpreter','none','FontSize',16);            
        end
        %-------------------------------------------
        function plot_all_3_struct(obj,spic_struct,tspan_ms,nr_of_sweeps)            
            if nr_of_sweeps>0
                nr_of_rows=nr_of_sweeps;
            else
                sp_t_max=max(cell2mat({spic_struct.spike_times_max}));
                sp_t_min=min(cell2mat({spic_struct.spike_times_min}));
                maxrow=max(sp_t_max);
                minrow=min(sp_t_min);
                nr_of_rows=maxrow-minrow+1;
            end
            obj.plotini('a4');          
            dotlength=obj.get_dotlength(nr_of_rows);
            obj.plot_xhisto_struct(spic_struct,tspan_ms,nr_of_rows);
            
            obj.plot_yhisto_struct(spic_struct,tspan_ms,nr_of_rows);
            obj.plot_dots_struct(spic_struct,tspan_ms,nr_of_rows,dotlength);
            if ~isempty(obj.title)
                title(obj.title,'Interpreter','none','FontSize',12);
            end
            if ~isempty(obj.subtitle)
                axes('position', [0.01, 0.985, 1, 0.01], 'visible', 'off')
                text(0,0,obj.subtitle,'Fontsize',12,'interpreter','none');
            end            
            if ~isempty(obj.legend1)
                x2=1; y2=1;
                axes('position', [obj.x_legend1, obj.y_legend1, x2, y2], 'visible', 'off')
                text(0,0,obj.legend1,'Fontsize',obj.points_legend1,'interpreter','none');
            end   
            if ~isempty(obj.legend2)
                x2=1; y2=1;
                axes('position', [obj.x_legend2, obj.y_legend2, x2, y2], 'visible', 'off')
                text(0,0,obj.legend2,'Fontsize',obj.points_legend2,'interpreter','none');
            end   
        end
        %-------------------------------------------
        function plot_all_3_struct_w(obj,spic_struct,resp_window_ms,nr_of_sweeps)
            % _w: jetzt start und end in resp_window_ms
            if nr_of_sweeps>0
                nr_of_rows=nr_of_sweeps;
            else
                sp_t_max=max(cell2mat({spic_struct.spike_times_max}));
                sp_t_min=min(cell2mat({spic_struct.spike_times_min}));
                maxrow=max(sp_t_max);
                minrow=min(sp_t_min);
                nr_of_rows=maxrow-minrow+1;
            end
            obj.plotini('a4');          
            dotlength=obj.get_dotlength(nr_of_rows);
            obj.plot_xhisto_struct(spic_struct,resp_window_ms(2)-resp_window_ms(1),nr_of_rows);
            
            obj.plot_yhisto_struct_w(spic_struct,resp_window_ms,nr_of_rows);
            obj.plot_dots_struct_w(spic_struct,resp_window_ms,nr_of_rows,dotlength);
            if ~isempty(obj.title)
                title(obj.title,'Interpreter','none','FontSize',12);
            end
            if ~isempty(obj.subtitle)
                axes('position', [0.01, 0.985, 1, 0.01], 'visible', 'off')
                text(0,0,obj.subtitle,'Fontsize',12,'interpreter','none');
            end            
            if ~isempty(obj.legend1)
                x2=1; y2=1;
                axes('position', [obj.x_legend1, obj.y_legend1, x2, y2], 'visible', 'off')
                text(0,0,obj.legend1,'Fontsize',obj.points_legend1,'interpreter','none');
            end   
            if ~isempty(obj.legend2)
                x2=1; y2=1;
                axes('position', [obj.x_legend2, obj.y_legend2, x2, y2], 'visible', 'off')
                text(0,0,obj.legend2,'Fontsize',obj.points_legend2,'interpreter','none');
            end   
        end
        %-------------------------------------------
        function dotlength=get_dotlength(obj,nr_of_rows)
            if nr_of_rows<=50
                dotlength=5;
            elseif nr_of_rows<=100
                dotlength=4;
            elseif nr_of_rows<=200
                dotlength=3;
            elseif nr_of_rows<=400
                dotlength=5;
            else
                dotlength=5;
            end
        end
        %-------------------------------------------    
        function tcolor=get_cat_color(obj,icat)
            while icat>4
                icat=icat-4;
            end
            %tcolors=[[1 0 0];[0 0 1];[1 1 0];[0 1 0]]; % yellow
            %tcolors=[[0.8 0 0];[0 0 0.8];[0.8 0.5 0];[0 0.9 0.2]];  % orange
            tcolors=[[0 0.4 0.97 ];[0.4 0 0.97];[0.97 0 0.4];[0.97 0.4 0]];  % abwechselnd 1-2 3-4
            tcolors=[[0 0.4 0.97 ];[0.0 0.7 0.0];[0.4 0 0.97];[0.97 0.4 0]];  % abwechselnd 1-2 3-4
            tcolor=tcolors(icat,:);
        end
        %-------------------------------------------
        function plot_yhisto_from_struct(obj,spik_struct,resp_window_ms)
            nr_of_sweeps=length(spik_struct);      
            xmax=resp_window_ms(2);
            xmin=resp_window_ms(1);
            obj.set_xlimits(3,xmin,xmax);
            nr_of_bins=ceil((xmax-xmin)/obj.plos(3).binwidth);
            hisvek=zeros(nr_of_bins,1);
            for isweep=1:nr_of_sweeps
                spike_times=spik_struct(isweep).spikes_in_window_ms-xmin;                
                for i=1:length(spike_times)
                    ibin=ceil(spike_times(i)/obj.plos(3).binwidth);
                    hisvek(ibin)=hisvek(ibin)+1;
                end               
            end
            hisvek=hisvek*1000/(obj.plos(3).binwidth*nr_of_sweeps);
            obj.plos(3).ax=axes('position',obj.plos(3).posvec);
            obj.plot_histo_area( 3,hisvek);
            set(gca,'YAxisLocation','right');
            axis tight;
            grid on;
        end
        %-------------------------------------------
        function plot_xhisto_from_struct(obj,spik_struct,resp_window_ms)
            nr_of_sweeps=length(spik_struct);      
            xmax=resp_window_ms(2);
            xmin=resp_window_ms(1);
            plot_ob=2;
            obj.set_xlimits(plot_ob,xmin,xmax);
            nr_of_bins=ceil((xmax-xmin)/obj.plos(plot_ob).binwidth);
            hisvek=zeros(nr_of_bins,1);
            for isweep=1:nr_of_sweeps
                spike_times=spik_struct(isweep).spikes_in_window_ms-xmin;                
                for i=1:length(spike_times)
                    ibin=ceil(spike_times(i)/obj.plos(plot_ob).binwidth);
                    if ibin<=nr_of_bins
                        hisvek(ibin)=hisvek(ibin)+1;
                    end
                end               
            end
            hisvek=hisvek*1000/(obj.plos(plot_ob).binwidth*nr_of_sweeps);
            obj.plos(plot_ob).ax=axes('position',obj.plos(plot_ob).posvec);
            view(90,90);
            set(gca,'XDir','Reverse');
            obj.plot_histo_area( plot_ob,hisvek);
            set(gca,'YAxisLocation','right');
            axis tight;
            grid on;
        end
                
        %-------------------------------------------
        function plot_scat_cor(obj,spik_struct_x,spik_struct_y,resp_window_ms)
            nr_of_sweeps=length(spik_struct_x);
            obj.plotini('a4');          
            obj.set_xlimits(1,resp_window_ms(1),resp_window_ms(2));            
            ymin=0;
            ymax=nr_of_sweeps;
            obj.set_ylimits(1,ymin,ymax);
            obj.set_xlimits(2,ymin,ymax);
            obj.plos(1).ax=axes('position',obj.plos(1).posvec);
            %set(gca,'YDir','Reverse');
            %set(gca,'YAxisLocation','right');
            
            set(gca, 'ylim', [obj.plos(1).ylimits(1) obj.plos(1).ylimits(2)]);
            set(gca, 'xlim', [obj.plos(1).xlimits(1) obj.plos(1).xlimits(2)]);
            
            axis tight;
            grid on;
            hold on;
            
            for isweep=1:nr_of_sweeps
                spikes_x=spik_struct_x(isweep).spikes_in_window_ms;
                spikes_y=spik_struct_y(isweep).spikes_in_window_ms;
                obj.scatterplot(spikes_x,spikes_y); %plot_dots_struct_w
                if isweep==1
                    hold on;
                end
            end
%             obj.plot_xhisto_struct(spic_struct_x,resp_window_ms(2)-resp_window_ms(1),nr_of_rows);            
%             obj.plot_yhisto_struct_w(spic_struct_x,resp_window_ms,nr_of_rows);
            if ~isempty(obj.title)
                title(obj.title,'Interpreter','none','FontSize',12);
            end
            obj.plot_yhisto_from_struct(spik_struct_x,resp_window_ms);
            obj.plot_xhisto_from_struct(spik_struct_y,resp_window_ms);
        end
        
        
function scatterplot(obj,x_spikes,y_spikes)
nr_x_spikes=length(x_spikes);
nr_y_spikes=length(y_spikes);
x=zeros(nr_x_spikes*nr_y_spikes,1);
y=zeros(nr_x_spikes*nr_y_spikes,1);
lentot=0;
for i=1:nr_x_spikes
    x(lentot+1:lentot+nr_y_spikes)=x_spikes(i);
    y(lentot+1:lentot+nr_y_spikes)=y_spikes;
    lentot=lentot+nr_y_spikes;
end
plot(x,y,'.');
end

        
        
        
        
        %-------------------------------------------
        function test2(obj)
            nr_of_sweeps=200;
            tspan_ms=1800;
            spike_times=rand(1000,1)*tspan_ms;
            spike_rows=ceil(rand(1000,1)*nr_of_sweeps);
            obj.plot_all_3(spike_times,spike_rows,tspan_ms,nr_of_sweeps);            
        end
    %-------------------------------------------
        function test3(obj) % different colors overlaid
            nr_of_sweeps=200;
            tspan_ms=1800;
            spic_struct=struct();
            
            spike_times=rand(1000,1)*tspan_ms;
            spike_rows=ceil(rand(1000,1)*nr_of_sweeps);
            spic_struct(1).spike_times=spike_times;   
            spic_struct(1).spike_times_max=max(spike_times);   
            spic_struct(1).spike_times_min=min(spike_times);   
            spic_struct(1).spike_rows=spike_rows*2;
            spic_struct(1).spike_rows_max=max(spike_rows)*2;
            spic_struct(1).spike_rows_min=min(spike_rows)*2;
            nr_of_sweeps2=300;            
            spike_times2=rand(500,1)*tspan_ms;
            %spike_rows2=ceil(rand(500,1)*nr_of_sweeps2)+nr_of_sweeps;
            spike_rows2=ceil(rand(500,1)*nr_of_sweeps2*2)+1;
            spic_struct(2).spike_times=spike_times2;
            spic_struct(2).spike_times_max=max(spike_times2);   
            spic_struct(2).spike_times_min=min(spike_times2);   
            spic_struct(2).spike_rows=spike_rows2;
            spic_struct(2).spike_rows_max=max(spike_rows2);
            spic_struct(2).spike_rows_min=min(spike_rows2);
            nr_of_sweeps=nr_of_sweeps2*2+1;
            obj.set_smooth(2,3);
            obj.set_smooth(3,1);
            obj.set_smooth2(2,23);
            obj.set_smooth2(3,11);
            nr_of_sweeps=0;
            obj.plot_all_3_struct(spic_struct,tspan_ms,nr_of_sweeps);  
        end
    end
end