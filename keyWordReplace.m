function [outContent] = keyWordReplace(inContent,settings)

outContent = inContent;
outContent = strrep(outContent,"MOLECULE_NAME",settings.MOLECULE_NAME);
outContent = strrep(outContent,"ABINITIO_METHOD",settings.ABINITIO_METHOD);
outContent = strrep(outContent,"ABINITIO_FUNCTIONAL",settings.ABINITIO_FUNCTIONAL);
outContent = strrep(outContent,"ABINITIO_BASISSET",settings.ABINITIO_BASISSET);
outContent = strrep(outContent,"ABINITIO_CORRECTIONS",settings.ABINITIO_CORRECTIONS);
outContent = strrep(outContent,"ABINITIO_NPROC",num2str(settings.ABINITIO_NPROC));
outContent = strrep(outContent,"ABINITIO_CHARGE",num2str(settings.ABINITIO_CHARGE));
outContent = strrep(outContent,"ABINITIO_MULT",num2str(settings.ABINITIO_MULT));
outContent = strrep(outContent,"ABINITIO_OPTIONS",settings.ABINITIO_OPTIONS);

end

