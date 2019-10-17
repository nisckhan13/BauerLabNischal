function [datahb]=dotspect(datamua,E)

% dotspect() performs spectroscopy on DOT <math>\frac{}{}\mu_a</math> data.
% 
% [datahb]=dotspect(datamua,E)
% 
% datamua is your absorption data, which must have a second-to-last
% dimension of color/wavelength. E is the spectroscopy matrix to use, which
% has dimensions wavelength x Hb contrast. If E is a square matrix, then
% the spectroscopy is performed with a simple matrix inversion. If E asks
% for fewer contrasts than there are wavelengths, then dotspect() should do
% a least-squares fitting, although this has never been tested. If there
% are more contrasts than wavelengths, the problem is obviously impossible
% to solve, resulting in an error. 
%
% (c) 2009 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

[Cin Cout]=size(E);

[datamua Sin Sout]=datacondition(datamua,2);
L=Sout(1);
T=Sout(end);



if Sin(end-1)==1
    error('** Your data must have more than one wavelength to perform spectroscopy **')
elseif Cout>Cin
    error('** Your spectroscopy problem is underdetermined **')
elseif Cout==Cin % matrix inversion
    iE=inv(E);
elseif Cout<Cin % least-squares fit: CHECK!
    iE=pinv(E);
end

if numel(Sin)>=3
    Sout(2)=Cout;
    
    % Initialize Outputs
    datahb=zeros(Sout);
    for h=1:Cout
        tseq=zeros(L,T);
        for c=1:Cin
            tseq=tseq+squeeze(iE(h,c))*squeeze(datamua(:,c,:));
        end
        datahb(:,h,:)=tseq;
    end
    
    datahb=reshape(datahb,[Sin(1:end-2) Cout Sin(end)]);
else
    datahb=zeros(Cout,T);
    for h=1:Cout
        tseq=zeros(1,T);
        for c=1:Cin
            tseq=tseq+squeeze(iE(h,c))*squeeze(datamua(c,:));
        end
        datahb(h,:)=tseq;
    end
end

    
end