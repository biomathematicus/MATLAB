function sFileName = funPrintImage(h,sName)
    % Create file with plot
    figure(h)
    %set(gca,'FontSize',nFontSize);
    sFileName = [ sName  '.jpg'] ;
    print ('-djpeg100', sFileName);
    funCropImage(sFileName);
    sFileName = [ sName  '.pdf'] ;
    %print ('-dpdf', sFileName);
    funPrintPDF(h,sFileName)
end

