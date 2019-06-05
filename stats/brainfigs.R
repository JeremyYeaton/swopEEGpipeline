library(rgl)
library(misc3d)
library(neurobase)
library(aal)
library(MNITemplate)
# if (!requireNamespace("aal")) {
#   devtools::install_github("muschellij2/aal")
# } else {
#   library(aal)
# }
# if (!requireNamespace("MNITemplate")) {
#   devtools::install_github("jfortin1/MNITemplate")
# } else {
#   library(MNITemplate)
# }
img = aal_image()
template = readMNI(res = "2mm")
cut <- 4500
dtemp <- dim(template)
# All of the sections you can label
labs = aal_get_labels()
# Pick the region of the brain you would like to highlight - in this case the hippocamus_L
Frontal_Inf_Orb_L
Frontal_Inf_Oper_L

caudate = labs$index[grep("Caudate_L", labs$name)]
cingulate = labs$index[grep("Cingulate_Ant_L", labs$name)]
idx = labs$index[grep("	Frontal_Inf_Tri_L", labs$name)]
# idx = c(caudate,cingulate)
mask = remake_img(vec = img %in% idx, img = img)

### this would be the ``activation'' or surface you want to render 
contour3d(template, x=1:dtemp[1], y=1:dtemp[2], z=1:dtemp[3], level = cut, alpha = 0.1, draw = TRUE)
contour3d(mask, level = c(0.5), alpha = c(0.5), add = TRUE, color=c("red") )
### add text
text3d(x=dtemp[1]/2, y=dtemp[2]/2, z = dtemp[3]*0.98, text="Top")
text3d(x=-0.98, y=dtemp[2]/2, z = dtemp[3]/2, text="Right")
rglwidget()