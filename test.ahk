#Requires AutoHotkey v2.0

global CardBuffer := ""

#HotIf
0::AppendDigit("0")
1::AppendDigit("1")
2::AppendDigit("2")
3::AppendDigit("3")
4::AppendDigit("4")
5::AppendDigit("5")
6::AppendDigit("6")
7::AppendDigit("7")
8::AppendDigit("8")
9::AppendDigit("9")

Space::FinishScan()

AppendDigit(digit)
{
    global CardBuffer
    CardBuffer .= digit
}

FinishScan()
{
    global CardBuffer

    if (CardBuffer = "")
        return

    CardCode := CardBuffer
    CardBuffer := ""

    Sleep(1000)

    SendText(CardCode)
    Send("{Enter}")
}