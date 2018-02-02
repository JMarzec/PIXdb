clear
echo "***--------------------------------------------------------------***"
echo "Welcome to the Breast Cancer Now Tissue Bank Analysis Workflow"
echo "Institution: Barts Cancer Institute"
echo "Principal Investigator: Prof. Claude Chelala"
echo "Authors: E. Gadaleta, J. Marzek, S. Pirro"
echo "This software is under Creative Common Licence"
echo "***--------------------------------------------------------------***"

echo ""
python main.py --pmids $1

echo "***--------------------------------------------------------------***"
echo "Thanks for using the BCNTB Analysis Workflow"
echo "***--------------------------------------------------------------***"
